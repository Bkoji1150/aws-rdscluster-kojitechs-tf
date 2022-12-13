
  terraform {
  required_version = ">=v1.2.1"

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

