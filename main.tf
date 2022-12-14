locals {
  create_cluster = var.create_cluster && var.putin_khuylo
  port                            = coalesce(var.port, (var.engine == "aurora-postgresql" ? 5432 : 3306))
  db_subnet_group_name            = var.create_db_subnet_group ? join("", aws_db_subnet_group.this.*.name) : var.db_subnet_group_name
  db_parameter_group_name         = var.create_db_parameter_group ? join("", aws_db_parameter_group.this.*.id) : var.db_parameter_group_name
  db_cluster_parameter_group_name = var.create_cluster_parameter_group ? join("", aws_rds_cluster_parameter_group.this.*.id) : var.db_cluster_parameter_group_name
 postgres_aurora = var.engine == "aurora-postgresql" ? 1 : 0
  master_password             = random_password.master_password.result
  lambda_description = var.rotation_type == "single" ? "Conducts an AWS SecretsManager secret rotation for RDS MySQL using single user rotation scheme" : "Conducts an AWS SecretsManager secret rotation for RDS MySQL using multi user rotation scheme"
  backtrack_window            = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0
  rds_enhanced_monitoring_arn = var.create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
  rds_security_group_id       = join("", aws_security_group.this.*.id)
  is_serverless               = var.engine_mode == "serverless"

  secrete_values = {
    engine   = "postgres"
    host     = try(aws_rds_cluster.this[0].endpoint, "")
    username = var.master_username
    password = random_password.master_password.result
    port     = local.port
    dbname   = var.database_name
  }

  common_tenable_values = {
    engine    = "postgres"
    host      = try(aws_rds_cluster.this[0].endpoint, "")
    dbname    = var.database_name
    port      = local.port
    masterarn = aws_secretsmanager_secret.default.arn
  }
}

resource "random_password" "users_password" {
  for_each = toset(var.db_users)
  length   = 16
  special  = false
}

resource "aws_kms_key" "default" {
  description         = "Key for Secrets Manager secret [${var.master_username}]"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "default" {
  name          = format("%s/%s", "alias", var.component_name)
  target_key_id = aws_kms_key.default.key_id
}


resource "aws_secretsmanager_secret" "default" {
  name_prefix = "${var.component_name}-${var.master_username}-"
  description = "Username and password for RDS user ${var.master_username} on ${aws_rds_cluster.this[0].id}"
  kms_key_id  = aws_kms_key.default.key_id
}

resource "aws_secretsmanager_secret" "users_secret" {

  for_each                = toset(keys(random_password.users_password))
  name_prefix             = format("%s-%s-", var.component_name, each.key)
  description             = "secret to manage user credential of ${each.key} on ${format("%s-%s", var.component_name, terraform.workspace)} instance"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.default.key_id
}

resource "aws_secretsmanager_secret_version" "master_secret_value" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = jsonencode(local.secrete_values)
}

# Secrets Manager for all application users that requires a password 
resource "aws_secretsmanager_secret_version" "user_secret_value" {
  depends_on = [
    aws_secretsmanager_secret_version.master_secret_value
  ]

  for_each      = toset(keys(aws_secretsmanager_secret.users_secret))
  secret_id     = aws_secretsmanager_secret.users_secret[each.key].id
  secret_string = jsonencode(merge(local.common_tenable_values, { username = each.key, password = random_password.users_password[each.key].result }))
}

resource "aws_secretsmanager_secret_rotation" "multiuser_sercrets" {
  depends_on = [
    aws_secretsmanager_secret_version.master_secret_value
  ]
  for_each = toset(keys(aws_secretsmanager_secret.users_secret))

  secret_id           = aws_secretsmanager_secret.users_secret[each.key].id
  rotation_lambda_arn = module.lambda_function.lambda_function_arn
  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}
resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "random_id" "snapshot_identifier" {
  count = local.create_cluster ? 1 : 0

  keepers = {
    id = var.name
  }

  byte_length = 4
}

resource "aws_db_subnet_group" "this" {
  count = local.create_cluster && var.create_db_subnet_group ? 1 : 0

  name        = lower(format("%s-%s", var.component_name, var.db_subnet_groupname))
  description = "For Aurora cluster ${var.name}"
  subnet_ids  = var.subnets
}

### PARAMETER GROUP
resource "aws_db_parameter_group" "this" {
  count = local.create_cluster && var.create_db_parameter_group ? 1 : 0

  name        = lower("${var.name}-aurora-db-${var.engine}-parameter-group")
  family      = var.engine == "aurora-postgresql" ? "aurora-postgresql11" : "aurora-mysql5.7"
  description = "${var.name}-aurora-db-${var.engine}-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = local.create_cluster && var.create_cluster_parameter_group ? 1 : 0

  name        = lower("${var.name}-aurora-${var.engine}-cluster-parameter-group")
  family      = var.engine == "aurora-postgresql" ? "aurora-postgresql11" : "aurora-mysql5.7"
  description = "${var.name}-aurora-${var.engine}-cluster-parameter-group"
}

resource "aws_rds_cluster" "this" {
  count = local.create_cluster ? 1 : 0

  global_cluster_identifier      = var.global_cluster_identifier
  enable_global_write_forwarding = var.enable_global_write_forwarding
  cluster_identifier             = lower(var.name)
  replication_source_identifier  = var.replication_source_identifier
  source_region                  = var.source_region

  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = local.is_serverless ? null : var.engine_version
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  enable_http_endpoint                = var.enable_http_endpoint
  kms_key_id                          = var.kms_key_id
  database_name                       = var.is_primary_cluster ? var.database_name : null
  master_username                     = var.is_primary_cluster ? var.master_username : null
  master_password                     = random_password.master_password.result
  final_snapshot_identifier           = "${var.final_snapshot_identifier_prefix}-${var.name}-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = local.is_serverless ? null : var.preferred_backup_window
  preferred_maintenance_window        = local.is_serverless ? null : var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = local.db_subnet_group_name
  vpc_security_group_ids              = compact(concat(aws_security_group.this.*.id, var.vpc_security_group_ids))
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = local.db_cluster_parameter_group_name
  db_instance_parameter_group_name    = var.allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = local.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 || !local.is_serverless ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  dynamic "s3_import" {
    for_each = var.s3_import != null && !local.is_serverless ? [var.s3_import] : []
    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  lifecycle {
    ignore_changes = [
      # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#replication_source_identifier
      # Since this is used either in read-replica clusters or global clusters, this should be acceptable to specify
      replication_source_identifier,
      # See docs here https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster#new-global-cluster-from-existing-db-cluster
      global_cluster_identifier,
    ]
  }

  tags = merge(var.tags, var.cluster_tags)
}

resource "aws_rds_cluster_instance" "this" {
  for_each = local.create_cluster && !local.is_serverless ? var.instances : {}

  # Notes:
  # Do not set preferred_backup_window - its set at the cluster level and will error if provided here

  identifier                            = var.instances_use_identifier_prefix ? null : lower(lookup(each.value, "identifier", "${var.name}-${each.key}"))
  identifier_prefix                     = var.instances_use_identifier_prefix ? lower(lookup(each.value, "identifier_prefix", "${var.name}-${each.key}-")) : null
  cluster_identifier                    = try(aws_rds_cluster.this[0].id, "")
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = local.db_subnet_group_name
  db_parameter_group_name               = local.db_parameter_group_name
  apply_immediately                     = lookup(each.value, "apply_immediately", var.apply_immediately)
  monitoring_role_arn                   = local.rds_enhanced_monitoring_arn
  monitoring_interval                   = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  promotion_tier                        = lookup(each.value, "promotion_tier", null)
  availability_zone                     = lookup(each.value, "availability_zone", null)
  preferred_maintenance_window          = lookup(each.value, "preferred_maintenance_window", var.preferred_maintenance_window)
  auto_minor_version_upgrade            = lookup(each.value, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_kms_key_id       = lookup(each.value, "performance_insights_kms_key_id", var.performance_insights_kms_key_id)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)
  copy_tags_to_snapshot                 = lookup(each.value, "copy_tags_to_snapshot", var.copy_tags_to_snapshot)
  ca_cert_identifier                    = var.ca_cert_identifier

  timeouts {
    create = lookup(var.instance_timeouts, "create", null)
    update = lookup(var.instance_timeouts, "update", null)
    delete = lookup(var.instance_timeouts, "delete", null)
  }

  # TODO - not sure why this is failing and throwing type mis-match errors
  # tags = merge(var.tags, lookup(each.value, "tags", {}))
  tags = var.tags
}

resource "aws_rds_cluster_endpoint" "this" {
  for_each = local.create_cluster && !local.is_serverless ? var.endpoints : tomap({})

  cluster_identifier          = try(aws_rds_cluster.this[0].id, "")
  cluster_endpoint_identifier = each.value.identifier
  custom_endpoint_type        = each.value.type

  static_members   = lookup(each.value, "static_members", null)
  excluded_members = lookup(each.value, "excluded_members", null)

  depends_on = [
    aws_rds_cluster_instance.this
  ]

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

resource "aws_rds_cluster_role_association" "this" {
  for_each = local.create_cluster ? var.iam_roles : {}

  db_cluster_identifier = try(aws_rds_cluster.this[0].id, "")
  feature_name          = each.value.feature_name
  role_arn              = each.value.role_arn
}

################################################################################
# Enhanced Monitoring
################################################################################

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = local.create_cluster && var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : var.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${var.iam_role_name}-" : null
  description = var.iam_role_description
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns   = var.iam_role_managed_policy_arns
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration

  tags = merge(
    { "Name" = var.name }
  )
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = local.create_cluster && var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

################################################################################
# Autoscaling
################################################################################

resource "aws_appautoscaling_target" "this" {
  count = local.create_cluster && var.autoscaling_enabled && !local.is_serverless ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${try(aws_rds_cluster.this[0].cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "this" {
  count = local.create_cluster && var.autoscaling_enabled && !local.is_serverless ? 1 : 0

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${try(aws_rds_cluster.this[0].cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.autoscaling_target_cpu : var.autoscaling_target_connections
  }

  depends_on = [
    aws_appautoscaling_target.this
  ]
}


################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = local.create_cluster && var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-"
  vpc_id      = var.vpc_id
  description = coalesce(var.security_group_description, "Control traffic to/from RDS Aurora ${var.name}")

  tags = merge(var.tags, var.security_group_tags, { Name = var.name })
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "default_ingress" {
  count = local.create_cluster && var.create_security_group ? length(var.allowed_security_groups) : 0

  description = "From allowed SGs"

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = local.rds_security_group_id
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "cidr_ingress" {
  count = local.create_cluster && var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = local.rds_security_group_id
}

resource "aws_security_group_rule" "egress" {
  for_each = local.create_cluster && var.create_security_group ? var.security_group_egress_rules : {}

  type              = "egress"
  from_port         = lookup(each.value, "from_port", local.port)
  to_port           = lookup(each.value, "to_port", local.port)
  protocol          = "tcp"
  security_group_id = local.rds_security_group_id

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

resource "aws_security_group" "lambda_secrets_rotation_sg" {

  name = "lambda-secrets-${var.component_name}-sg"
  description = "Allow lambda inbound access on rds"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lambda-secrets-${var.component_name}-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "postgres_port_allow_ecs" {

  security_group_id        =  local.rds_security_group_id
  description              = "Allow lambda ingress access to db cluster on port ${local.port}"
  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_secrets_rotation_sg.id
}

resource "random_pet" "this" {
  length = 2
}

module "s3_bucket" {

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${random_pet.this.id}-"
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  depends_on    = [aws_rds_cluster.this]
  function_name = "${var.component_name}-function"
  description   = local.lambda_description
  handler       = "lambda_function.lambda_handler"
  runtime       = var.runtime 
  publish       = true
  timeout       = var.timeout

  lambda_role = aws_iam_role.default.arn
  create_role = false
  source_path = "${path.module}/functions/MultiUser"
  store_on_s3 = true
  s3_bucket   = module.s3_bucket.s3_bucket_id

  environment_variables = {
    SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com",
    SLACK_WEBHOOK_ENDPOINT   = var.slack_token
  }
  allowed_triggers = {
    ScanAmiRule = {
      principal    = "secretsmanager.amazonaws.com"
      statement_id = "AllowExecutionSecretManager"
    }
  }
  vpc_subnet_ids         = var.subnets
  vpc_security_group_ids = [aws_security_group.lambda_secrets_rotation_sg.id]

  tags = {
    Module = "${var.component_name}-function"
  }
}
