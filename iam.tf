
resource "aws_iam_role" "ssm_fleet_instance" {
  name = "${var.component_name}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.component_name}-ssm-role"
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.component_name}-ssm-fleet-instance-profile"
  role = aws_iam_role.ssm_fleet_instance.name
}

resource "aws_iam_policy" "policy" {
  name        = "${var.component_name}-ssm-policy"
  description = "allow ecs instance to be managed by ssm"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }   
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ssm_fleet_instance.name
  policy_arn = aws_iam_policy.policy.arn
}

##### SECRETS 
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "service" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationMultiUserRolePolicy0" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationSingleUserRolePolicy0" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationMultiUserRolePolicy1" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:resource/AllowRotationLambdaArn"
      values   = ["arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${module.lambda_function.lambda_function_name}"]
    }

    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
    ]
  }

  statement {
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationSingleUserRolePolicy1" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    condition {
      test     = "StringEquals"
      variable = "secretsmanager:resource/AllowRotationLambdaArn"
      values   = ["arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${module.lambda_function.lambda_function_name}"]
    }
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
    ]

  }

  statement {
    actions   = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationMultiUserRolePolicy4" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = [aws_kms_key.default.arn]
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationSingleUserRolePolicy2" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = [aws_kms_key.default.arn]
  }
}

data "aws_iam_policy_document" "SecretsManagerPostgresQlRotationMultiUserRolePolicy2" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid     = "Enable IAM User Permissions"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow access for Key Administrators"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] # TODO
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow use of the key"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.default.arn]
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.default.arn]
    }
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "default" {
  name               = "${var.component_name}-password-rotation"
  assume_role_policy = data.aws_iam_policy_document.service.json
}

resource "aws_iam_role_policy_attachment" "lambda-basic" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-vpc" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationSingleUserRolePolicy0" {
  count  = var.rotation_type == "single" ? 1 : 0
  name   = "SecretsManagerPostgresQlRotationSingleUserRolePolicy0"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationSingleUserRolePolicy0.json
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationSingleUserRolePolicy1" {
  count  = var.rotation_type == "single" ? 1 : 0
  name   = "SecretsManagerPostgresQlRotationSingleUserRolePolicy1"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationSingleUserRolePolicy1.json
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationSingleUserRolePolicy2" {
  count  = var.rotation_type == "single" ? 1 : 0
  name   = "SecretsManagerPostgresQlRotationSingleUserRolePolicy2"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationSingleUserRolePolicy2.json
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationMultiUserRolePolicy0" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerPostgresQlRotationMultiUserRolePolicy0"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationMultiUserRolePolicy0.json
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationMultiUserRolePolicy1" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerPostgresQlRotationMultiUserRolePolicy1"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationMultiUserRolePolicy1.json
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationMultiUserRolePolicy2" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerPostgresQlRotationMultiUserRolePolicy2"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationMultiUserRolePolicy2.json
}

resource "aws_iam_role_policy" "SecretsManagerPostgresQlRotationMultiUserRolePolicy4" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerPostgresQlRotationMultiUserRolePolicy4"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerPostgresQlRotationMultiUserRolePolicy4.json
}
