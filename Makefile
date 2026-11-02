.PHONY: check-tools install-tools init-budget clean help

SHELL := /bin/bash
PATH := /opt/homebrew/bin:/usr/local/bin:$(PATH)

help:
	@echo "AWS DevOps Mastery — Commandes disponibles :"
	@echo "  make check-tools    Vérifier la présence des binaires nécessaires"
	@echo "  make install-tools  Installer les CLI manquants via Homebrew"
	@echo "  make install-cdk    Installer globalement la CLI AWS CDK"
	@echo "  make init-budget    Déployer l'alerte de budget de sécurité (5$) via Terraform"

check-tools:
	@bash 00-prerequisites/setup.sh

install-tools:
	@echo "Installation des outils via Homebrew..."
	brew install awscli hashicorp/tap/terraform node infracost tflint

install-cdk:
	@echo "Installation d'AWS CDK CLI via npm..."
	npm install -g aws-cdk

