output "audit_logs_bucket" {
  description = "Nom du bucket S3 hébergeant les journaux d'audit (Chiffré AES256 gratuit)"
  value       = aws_s3_bucket.audit_logs.id
}

output "cloudtrail_arn" {
  description = "ARN de la piste CloudTrail multi-région"
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "ID du détecteur GuardDuty (Essai 30 jours gratuit)"
  value       = length(aws_guardduty_detector.primary) > 0 ? aws_guardduty_detector.primary[0].id : null
}
