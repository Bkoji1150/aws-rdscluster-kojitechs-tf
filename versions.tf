#terraform {
#  required_version = ">= 0.13"
#
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = ">= 3.63"
#    }
#
#    random = {
#      source  = "hashicorp/random"
#      version = ">= 2.2"
#    }
#  }
#}

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
