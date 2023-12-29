resource "aws_iam_group" "inline_group" {
  name = "sadcloud-inline-group"

  count = var.inline_group_policy ? 1 : 0
}

resource "aws_iam_group_policy" "inline_group_policy" {
    group = aws_iam_group.inline_group[0].id

    count = var.inline_group_policy ? 1 : 0

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "inline_user" {
  name = "sadcloud-inline-user"

  count = var.inline_user_policy ? 1 : 0
}

resource "aws_iam_user_policy" "inline_user_policy" {
  user = aws_iam_user.inline_user[0].name

  count = var.inline_user_policy ? 1 : 0

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": "s3:DeleteBucket",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "inline_role" {

  name_prefix = "sadcloud-inline-role-policy-"

  count = var.inline_role_policy ? 1 : 0

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "inline_role_policy" {
  name = "inline-role-policy"
  role = aws_iam_role.inline_role[0].id

  count = var.inline_role_policy ? 1 : 0


  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "NotAction": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "trust_all_with_mfa" {

  count = (var.assume_role_policy_allows_all && !var.assume_role_no_mfa) ? 1 : 0

  name_prefix = "sadcloud-trust-all-with-mfa-"

  inline_policy {
    name = "deny-all"
    policy = data.aws_iam_policy_document.deny_all.json
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "trust_all_without_mfa" {

  count = (var.assume_role_policy_allows_all && var.assume_role_no_mfa) ? 1 : 0

  name_prefix = "sadcloud-trust-all-without-mfa-"

  inline_policy {
    name = "deny-all"
    policy = data.aws_iam_policy_document.deny_all.json
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_account_password_policy" "main" {
  count = (var.password_policy_minimum_length || var.password_policy_no_lowercase_required || var.password_policy_no_numbers_required || var.password_policy_no_uppercase_required || var.password_policy_no_symbol_required || var.password_policy_reuse_enabled || var.password_policy_expiration_threshold) ? 1 : 0

  minimum_password_length        = !var.password_policy_minimum_length ? 8 : 6
  require_lowercase_characters   = !var.password_policy_no_lowercase_required
  require_numbers                = !var.password_policy_no_numbers_required
  require_uppercase_characters   = !var.password_policy_no_uppercase_required
  require_symbols                = !var.password_policy_no_symbol_required
  password_reuse_prevention      = !var.password_policy_reuse_enabled ? 5 : 0
  max_password_age = var.password_policy_expiration_threshold ? 0 : 60
}

resource "aws_iam_policy" "policy" {
  count = var.admin_iam_policy ? 1 : 0

  name_prefix = "sadcloud-wildcard_IAM_policy"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group" "admin_not_indicated" {
  count = var.admin_not_indicated_policy ? 1 : 0

  name = "sadcloud-superuser"
  path = "/"
}



resource "aws_iam_policy" "admin_not_indicated_policy" {
  count = var.admin_not_indicated_policy ? 1 : 0


  name  = "sadcloud-superuser-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "admin_not_indicated_policy-attach" {
  group = aws_iam_group.admin_not_indicated[0].id
  policy_arn = aws_iam_policy.admin_not_indicated_policy[0].arn
  count = var.admin_not_indicated_policy ? 1 : 0
}

data "aws_iam_policy_document" "deny_all" {
  statement {
    effect = "Deny"
    actions   = ["*"]
    resources = ["*"]
  }
}