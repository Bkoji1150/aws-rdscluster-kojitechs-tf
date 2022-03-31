
locals {
  name   =  "kojitechs-${replace(basename(var.component_name), "_", "-")}"
  region = "us-east-1"
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
  source = "git::git@github.com:Bkoji1150/kojitechs-tf-aws-required-tags.git"

  line_of_business        = var.line_of_business
  ado                     = var.ado
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = var.tech_poc_primary
  tech_poc_secondary      = var.tech_poc_secondary
  application             = "rds_database_Aurora_cluster"
  builder                 = var.builder
  application_owner       = var.application_owner
  vpc                     = var.cell_name
  cell_name               = var.cell_name
  component_name          = format("%s-%s", var.component_name, terraform.workspace)
}

locals {
  operational_state   = data.terraform_remote_state.operational_environment.outputs
  vpc_id              = local.operational_state.vpc_id
  public_subnet_ids   = local.operational_state.public_subnets
  private_subnets_ids = local.operational_state.private_subnets
  public_subnets_cidrs     = local.operational_state.public_subnet_cidr_block
  db_subnets_names = local.operational_state.db_subnets_names
  private_sunbet_cidrs = local.operational_state.private_subnets_cidrs
}

################################################################################
# Supporting Resources
################################################################################


################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source = "../../"

  name           = local.name
  engine         = "aurora-postgresql"
  engine_version = "11.12"
  instances = {
    1 = {
      instance_class      = "db.r5.2xlarge"
      publicly_accessible = true
    }
#    2 = {
#      identifier     = "static-member-1"
#      instance_class = "db.r5.2xlarge"
#    }
    2 = {
      identifier     = format("%s-%s", var.component_name, "writer-instance")
      instance_class = "db.r5.large"
      promotion_tier = 15
    }
  }

  endpoints = {
#    static = {
#      identifier     = "static-custom-endpt"
#      type           = "ANY"
#      static_members = ["static-member-1"]
#      tags           = { Endpoint = "static-members" }
#    }
    excluded = {
      identifier       = "excluded-custom-endpt"
      type             = "READER"
      excluded_members = ["excluded-member-1"]
      tags             = { Endpoint = "excluded-members" }
    }
  }

  vpc_id                 =  local.vpc_id
  db_subnet_group_name   = local.db_subnets_names

  create_db_subnet_group = false
  create_security_group  = true
  allowed_cidr_blocks    = local.public_subnets_cidrs
  security_group_egress_rules = {
    to_cidrs = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Egress to corporate printer closet"
    }
  }
  iam_database_authentication_enabled = true
# db_users                     = var.db_users
  create_random_password              = false

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id
  enabled_cloudwatch_logs_exports = ["postgresql"]
  subnets = local.public_subnet_ids # only bc we want to connect local
  master_username = var.master_username
}

resource "aws_db_parameter_group" "example" {
  name        = "${var.component_name}-aurora-db-postgres11-parameter-group"
  family      = "aurora-postgresql11"
  description = "${var.component_name}-aurora-db-postgres11-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "${var.component_name}-aurora-postgres11-cluster-parameter-group"
  family      = "aurora-postgresql11"
  description = "${var.component_name}-aurora-postgres11-cluster-parameter-group"

}

