resource "aws_efs_file_system" "this" {
  count = var.create ? 1 : 0

  creation_token = var.prefix
  encrypted      = true

  tags = var.default_tags
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.create ? var.subnet_ids : [])

  file_system_id  = resource.aws_efs_file_system.this[0].id
  subnet_id       = each.value
  security_groups = var.security_groups
}

resource "aws_efs_file_system_policy" "this" {
  file_system_id = resource.aws_efs_file_system.this[0].id
  policy         = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = format("efs-statement-%s-policy", var.prefix)
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]

    resources = [resource.aws_efs_file_system.this[0].arn]

    # condition {
    #   test     = "Bool"
    #   variable = "aws:SecureTransport"
    #   values   = ["true"]
    # }

    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }

  statement {
    sid    = format("efs-statement-%s-users", var.prefix)
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for arn in data.aws_iam_roles.this.arns : arn]
    }

    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]

    resources = [resource.aws_efs_file_system.this[0].arn]

  }
}

data "aws_subnet" "this" {
  id = var.subnet_ids[0]
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}

data "aws_iam_roles" "this" {
  name_regex = join("|", var.iam_roles)
}
