data "aws_ssoadmin_instances" "main" {
}

locals {
    sso_instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
    identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

resource "aws_identitystore_group" "developers" {
    display_name = "Developers"
    description = "Engineers working with the sandbox account"
    identity_store_id = local.identity_store_id
}

resource "aws_identitystore_group" "security_auditors" {
    display_name = "SecurityAuditors"
    description = "security team with read-only access to all accounts"
    identity_store_id = local.identity_store_id
}

resource "aws_ssoadmin_permission_set" "developer" {
    name = "Developer"
    description = "Allow access to all Aws services excluding IAM, roles and organization"
    instance_arn = local.sso_instance_arn
    session_duration = "PT4H"
}

resource "aws_ssoadmin_permission_set" "security_auditors" {
    name = "SecurityAudit"
    description = "Grants Readonlyaccess to security settings"
    instance_arn = local.sso_instance_arn
    session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "developer_power_user" {
    instance_arn = local.sso_instance_arn
    managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
    permission_set_arn = aws_ssoadmin_permission_set.developer.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "security_audit" {
    instance_arn = local.sso_instance_arn
    managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
    permission_set_arn = aws_ssoadmin_permission_set.security_auditors.arn
}


resource "aws_identitystore_user" "test_user" {
    identity_store_id = local.identity_store_id

display_name = "Emmanuel Obi"
user_name = "Emmanuel"

name {
    given_name = "Emmanuel"
    family_name = "Obi"
}

emails {
    value = var.identitystore_user_email
}
}

resource "aws_identitystore_group_membership" "test" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.developers.group_id
  member_id = aws_identitystore_user.test_user.user_id
}