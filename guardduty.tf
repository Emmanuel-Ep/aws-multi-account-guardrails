resource "aws_guardduty_detector" "my_detector" {
    enable = true
}

resource "aws_organizations_account" "security" {
  name      = "Emmanuel-security"
  email     = var.security_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_guardduty_detector" "security" {
  provider = aws.security
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "security" {
  admin_account_id = aws_organizations_account.security.id

  depends_on = [aws_guardduty_detector.security]
}

resource "aws_guardduty_organization_configuration" "all_accounts" {
  provider                         = aws.security
  detector_id                      = aws_guardduty_detector.security.id
  auto_enable_organization_members = "ALL"

  depends_on = [aws_guardduty_organization_admin_account.security]
}