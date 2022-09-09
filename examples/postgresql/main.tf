
locals {
  name = "kojitechs-${replace(basename(var.component_name), "_", "-")}"
}

data "terraform_remote_state" "operational_environment" {
  backend = "s3"

  config = {
    region = "us-east-1"
    bucket = "operational.vpc.tf.kojitechs"
    key    = format("env:/%s/path/env", lower(terraform.workspace))
  }
}

module "required_tags" {
  source = "git::https://github.com/Bkoji1150/kojitechs-tf-aws-required-tags.git?ref=v1.0.0"

  line_of_business        = var.line_of_business
  ado                     = var.ado
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = var.tech_poc_primary
  tech_poc_secondary      = var.builder
  application             = var.application
  builder                 = var.builder
  application_owner       = var.application_owner
  vpc                     = var.vpc
  cell_name               = var.cell_name
  component_name          = var.component_name
}

locals {
  operational_state    = data.terraform_remote_state.operational_environment.outputs
  vpc_id               = local.operational_state.vpc_id
  public_subnet_ids    = local.operational_state.public_subnets
  private_subnets_ids  = local.operational_state.private_subnets
  public_subnets_cidrs = local.operational_state.public_subnet_cidr_block
  db_subnets_names     = local.operational_state.db_subnets_names
  private_sunbet_cidrs = local.operational_state.private_subnets_cidrs
}


################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source = "../../"

  component_name = var.component_name
  name           = local.name
  engine         = "aurora-postgresql"
  engine_version = "11.12"
  instances = {
    1 = {
      instance_class      = "db.r5.2xlarge"
      publicly_accessible = false
    }
    2 = {
      identifier     = format("%s-%s", var.component_name, "writer-instance")
      instance_class = "db.r5.large"
      promotion_tier = 15
    }
  }
  endpoints = {
  }
  vpc_id                 = local.vpc_id
  db_subnet_group_name   = local.db_subnets_names
  create_db_subnet_group = false
  allowed_cidr_blocks    = local.private_sunbet_cidrs
  subnets                = local.private_subnets_ids

  create_security_group = true
  security_group_egress_rules = {
    to_cidrs = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Egress to corporate printer closet"
    }
  }
  iam_database_authentication_enabled = true

  apply_immediately   = true
  skip_final_snapshot = true

  enabled_cloudwatch_logs_exports = ["postgresql"]
  database_name                   = "postgres_aurora"
  master_username                 = var.master_username
}

