
terraform {
  required_version = "~> 1.1.5"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.aws_account_id, terraform.workspace)}:role/Role_For-S3_Creation"
  }
  default_tags {
    tags = module.required_tags.aws_default_tags
  }
}

terraform {
  required_version = ">=1.1.5"

  backend "s3" {
    bucket = "state.tf.aws.rdscluster.kojitechs"
    key    = "terraform.tfstate/rdscluster"
    dynamodb_table = "terraform-lock"
    region = "us-east-1"
    encrypt = true
  }
}
