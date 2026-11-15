resource "aws_organizations_organizational_unit" "production" {
    name = "production"
    parent_id = "r-w1d3"
}

resource "aws_organizations_organizational_unit" "security" {
    name = "security"
    parent_id = "r-w1d3"
}

resource "aws_organizations_organizational_unit" "sandbox" {
    name = "sandbox"
    parent_id = "r-w1d3"
}


import {
  to = aws_organizations_organizational_unit.development
  id = "ou-w1d3-1s02ai6o"
}

resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = "r-w1d3"
}


resource "aws_organizations_policy" "protect_logging" {
  name    = "protect-logging"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/protect-logging.json")
}

resource "aws_organizations_policy_attachment" "protect_logging_root" {
  policy_id = aws_organizations_policy.protect_logging.id
  target_id = "r-w1d3"
}


resource "aws_organizations_account" "sandbox" {
  name      = "Emmanuel-sandbox"
  email     = var.sandbox_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.sandbox.id

  lifecycle {
    prevent_destroy = true
  }
}