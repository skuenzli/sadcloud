data "aws_caller_identity" "current" {}

locals {
  account_root_user_arn="arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

resource "aws_kms_key" "main" {
  description             = "sadcloud unrotated key"
  enable_key_rotation = !var.key_rotation_disabled

  count = var.key_rotation_disabled ? 1 : 0
}

resource "aws_kms_alias" "main" {
  name          = "alias/sadcloud-unrotated"
  target_key_id = aws_kms_key.main[0].key_id

  count = var.key_rotation_disabled ? 1 : 0
}

resource "aws_kms_key" "exposed" {
  description             = "sadcloud exposed key"
  enable_key_rotation = true

  count = var.kms_key_exposed ? 1 : 0

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-insecure-1",
  "Statement": [
    {
      "Sid": "Enable root user and identity policies",
      "Effect": "Allow",
      "Principal": {"AWS" : "${local.account_root_user_arn}"},
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Expose key to world",
      "Effect": "Allow",
      "Principal": {"AWS" : "*"},
      "Action": [
        "kms:DescribeKey",
        "kms:GetKeyRotationStatus",
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "exposed" {
  name          = "alias/sadcloud-exposed"
  target_key_id = aws_kms_key.exposed[0].key_id

  count = var.kms_key_exposed ? 1 : 0
}
