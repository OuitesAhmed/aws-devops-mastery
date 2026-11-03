#!/usr/bin/env python3
"""
AWS FinOps & Cost Optimization Audit Tool
-----------------------------------------
Script d'audit d'infrastructure AWS pour détecter les ressources orphelines,
les gaspillages financiers et les opportunités d'économies immédiates.
"""

import sys
import boto3
from datetime import datetime, timezone, timedelta
from botocore.exceptions import ClientError

def check_unattached_ebs(ec2):
    print("\n🔍 1. Recherche de volumes EBS orphelins (inutilisés mais facturés)...")
    try:
        volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])['Volumes']
        if not volumes:
            print("   ✅ Aucun volume EBS orphelin détecté (0 € gaspillé).")
            return 0, 0
        total_size = sum(v['Size'] for v in volumes)
        est_cost = total_size * 0.08 # ~0.08$/GB/mois gp3
        print(f"   ⚠️  ATTENTION : {len(volumes)} volume(s) orphelin(s) trouvé(s) ! ({total_size} Go)")
        for v in volumes:
            print(f"      - VolumeId: {v['VolumeId']} ({v['Size']} Go, Type: {v['VolumeType']})")
        print(f"      👉 Économie potentielle : ~{est_cost:.2f} $/mois en les supprimant.")
        return len(volumes), est_cost
    except ClientError as e:
        print(f"   [-] Erreur vérification EBS : {e}")
        return 0, 0

def check_unassociated_eips(ec2):
    print("\n🔍 2. Recherche d'adresses IP Élastiques (EIP) non associées...")
    try:
        eips = ec2.describe_addresses()['Addresses']
        unassociated = [ip for ip in eips if 'AssociationId' not in ip]
        if not unassociated:
            print("   ✅ Aucune adresse IP Élastique inutilisée.")
            return 0, 0
        est_cost = len(unassociated) * 3.60 # ~0.005$/h = ~3.60$/mois par EIP inactive
        print(f"   ⚠️  ATTENTION : {len(unassociated)} IP(s) Élastique(s) inactive(s) facturée(s) !")
        for ip in unassociated:
            print(f"      - AllocationId: {ip.get('AllocationId')} (IP: {ip.get('PublicIp')})")
        print(f"      👉 Économie potentielle : ~{est_cost:.2f} $/mois en les libérant.")
        return len(unassociated), est_cost
    except ClientError as e:
        print(f"   [-] Erreur vérification EIP : {e}")
        return 0, 0

def check_old_snapshots(ec2, account_id):
    print("\n🔍 3. Recherche de vieux snapshots EBS (> 90 jours)...")
    cutoff = datetime.now(timezone.utc) - timedelta(days=90)
    try:
        snapshots = ec2.describe_snapshots(OwnerIds=[account_id])['Snapshots']
        old_snaps = [s for s in snapshots if s['StartTime'] < cutoff]
        if not old_snaps:
            print("   ✅ Aucun vieux snapshot EBS (> 90 jours) détecté.")
            return 0
        print(f"   ℹ️  {len(old_snaps)} snapshot(s) de plus de 90 jours trouvé(s).")
        return len(old_snaps)
    except ClientError as e:
        print(f"   [-] Erreur vérification snapshots : {e}")
        return 0

def check_cloudwatch_retention(logs):
    print("\n🔍 4. Vérification de la rétention des groupes de journaux CloudWatch...")
    try:
        log_groups = logs.describe_log_groups()['logGroups']
        no_retention = [lg for lg in log_groups if 'retentionInDays' not in lg]
        if not no_retention:
            print(f"   ✅ Tous les groupes de logs ({len(log_groups)}) ont une politique de rétention finie.")
            return 0
        print(f"   ⚠️  ATTENTION : {len(no_retention)} groupe(s) de logs conservent leurs journaux indéfiniment !")
        for lg in no_retention:
            print(f"      - LogGroup: {lg['logGroupName']} (Taille actuelle: {lg.get('storedBytes', 0) / (1024*1024):.2f} Mo)")
        print("      👉 Recommandation : Fixer une rétention à 7 ou 30 jours pour éviter une accumulation infinie de frais.")
        return len(no_retention)
    except ClientError as e:
        print(f"   [-] Erreur vérification CloudWatch : {e}")
        return 0

def check_s3_lifecycle(s3):
    print("\n🔍 5. Vérification des règles de cycle de vie S3 (Lifecycle Policies)...")
    try:
        buckets = s3.list_buckets().get('Buckets', [])
        without_lifecycle = []
        for b in buckets:
            b_name = b['Name']
            try:
                s3.get_bucket_lifecycle_configuration(Bucket=b_name)
            except ClientError as e:
                if e.response['Error']['Code'] == 'NoSuchLifecycleConfiguration':
                    without_lifecycle.append(b_name)
        if not without_lifecycle:
            print(f"   ✅ Tous les buckets S3 ont des règles de cycle de vie.")
        else:
            print(f"   ℹ️  {len(without_lifecycle)} bucket(s) sans politique de transition automatique vers Glacier :")
            for name in without_lifecycle:
                print(f"      - {name}")
            print("      👉 Recommandation : Configurer une règle de transition S3 Glacier après 90 jours pour les archives.")
        return len(without_lifecycle)
    except ClientError as e:
        print(f"   [-] Erreur vérification S3 : {e}")
        return 0

def main():
    print("=" * 65)
    print("       🚀 RAPPORT D'AUDIT FINOPS & OPTIMISATION AWS")
    print("=" * 65)

    region = "eu-west-3"
    session = boto3.Session(region_name=region)
    sts = session.client('sts')
    try:
        caller = sts.get_caller_identity()
        account_id = caller['Account']
        print(f"Compte cible : {account_id}")
        print(f"Région auditée : {region}")
        print(f"Date de l'audit : {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
    except Exception as e:
        print(f"Erreur d'authentification AWS : {e}")
        sys.exit(1)

    ec2 = session.client('ec2')
    logs = session.client('logs')
    s3 = session.client('s3')

    unattached_ebs_count, ebs_savings = check_unattached_ebs(ec2)
    unassociated_eip_count, eip_savings = check_unassociated_eips(ec2)
    old_snaps_count = check_old_snapshots(ec2, account_id)
    cw_no_retention_count = check_cloudwatch_retention(logs)
    s3_no_lifecycle_count = check_s3_lifecycle(s3)

    total_est_monthly_savings = ebs_savings + eip_savings

    print("\n" + "=" * 65)
    print("                  📊 SYNTHÈSE DE L'AUDIT")
    print("=" * 65)
    print(f"• Économies directes potentielles : ~{total_est_monthly_savings:.2f} $/mois")
    print(f"• Volumes EBS orphelins : {unattached_ebs_count}")
    print(f"• IP Élastiques orphelines : {unassociated_eip_count}")
    print(f"• Snapshots anciens (> 90 j) : {old_snaps_count}")
    print(f"• Groupes CloudWatch sans expiration : {cw_no_retention_count}")
    print(f"• Buckets S3 sans règle de cycle de vie : {s3_no_lifecycle_count}")
    print("=" * 65)
    print("Audit terminé avec succès.\n")

if __name__ == '__main__':
    main()

