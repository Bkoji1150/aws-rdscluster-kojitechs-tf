
variable "aws_account_id" {
  description = "Environment this template would be deployed to"
  type        = map(string)
  default = {
    prod = "735972722491"
    sbx  = "674293488770"
  }
}

variable "application_owner" {
  description = "Email Group for the Application owner."
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "builder" {
  description = "Email for the builder of this infrastructure"
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "tech_poc_primary" {
  description = "Primary Point of Contact for Technical support for this service."
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "ado" {
  description = "Compainy name for this project"
  type        = string
  default     = "Kojitechs"
}

variable "tier" {
  type        = string
  description = "Canonical name of the application tier"
  default     = "DATA"
}

variable "cell_name" {
  description = "Name of the ECS cluster to deploy the service into."
  type        = string
  default     = "APP"
}

variable "component_name" {
  description = "Name of the component."
  type        = string
  default     = "hqr-common-database"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "postgres"
}

variable "application" {
  description = "Logical name for the application. Mainly used for kojitechs. For an ADO/LOB owned application default to the LOB name."
  type        = string
  default     = "test-postgres"
}

variable "line_of_business" {
  description = "HIDS LOB that owns the resource."
  type        = string
  default     = "TECH"
}

variable "vpc" {
  description = "The VPC the resource resides in. We need this to differentiate from Lifecycle Environment due to INFRA and SEC. One of \"APP\", \"INFRA\", \"SEC\", \"ROUTING\"."
  type        = string
  default     = "APP"
}
