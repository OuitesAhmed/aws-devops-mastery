# Bloquage global et systématique de tout S3 public au niveau du compte entier
resource "aws_s3_account_public_access_block" "account_level" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Politique de mot de passe stricte (Conformité CIS Benchmark / SOC2 / ISO 27001)
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}

