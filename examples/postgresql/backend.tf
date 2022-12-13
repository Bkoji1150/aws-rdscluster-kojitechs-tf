
terraform {
  required_version = ">=v1.2.1"

  backend "s3" {
    bucket         = "kojitechs.aws.eks.with.terraform.tf"
    dynamodb_table = "terraform-lock"
    key            = "path/env/aws-rdscluster-kojitechs-tf" #
    region         = "us-east-1"
    encrypt        = "true"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.18.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.aws_account_id, terraform.workspace)}:role/Role_For-S3_Creation"
  }
  default_tags {
    tags = module.required_tags.aws_default_tags
  }
}
