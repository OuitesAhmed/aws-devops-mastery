#!/usr/bin/env bash
set -euo pipefail

echo "============================================="
echo "  AWS DevOps Mastery — Vérification & Setup  "
echo "============================================="

# Détection de l'architecture Mac (Apple Silicon / Intel)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "1. Vérification des outils nécessaires..."

MISSING_BREW_PACKAGES=()

if ! command_exists aws; then
    echo "[-] AWS CLI n'est pas installé."
    MISSING_BREW_PACKAGES+=("awscli")
else
    echo "[✓] AWS CLI est présent : $(aws --version 2>&1 | head -n1)"
fi

if ! command_exists terraform; then
    echo "[-] Terraform n'est pas installé."
    MISSING_BREW_PACKAGES+=("hashicorp/tap/terraform")
else
    echo "[✓] Terraform est présent : $(terraform --version 2>&1 | head -n1)"
fi

if ! command_exists node; then
    echo "[-] Node.js n'est pas installé."
    MISSING_BREW_PACKAGES+=("node")
else
    echo "[✓] Node.js est présent : $(node --version)"
fi

if ! command_exists infracost; then
    echo "[-] Infracost n'est pas installé."
    MISSING_BREW_PACKAGES+=("infracost")
else
    echo "[✓] Infracost est présent : $(infracost --version 2>&1 | head -n1)"
fi

if [ ${#MISSING_BREW_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo "Paquets à installer via Homebrew : ${MISSING_BREW_PACKAGES[*]}"
    echo "Commande recommandée :"
    echo "  brew install ${MISSING_BREW_PACKAGES[*]}"
else
    echo ""
    echo "[✓] Tous les binaires de base sont installés !"
fi

# Vérification AWS CDK via npm si node est présent
if command_exists npm; then
    if ! command_exists cdk; then
        echo "[-] AWS CDK CLI n'est pas installé."
        echo "Commande recommandée :"
        echo "  npm install -g aws-cdk"
    else
        echo "[✓] AWS CDK est présent : $(cdk --version 2>&1)"
    fi
fi

