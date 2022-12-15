
variable "aws_account_id" {
  description = "Environment this template would be deployed to"
  type        = map(string)

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

variable "db_users" {
  description = "List of all databases"
  type        = list(any)
  default     = []
}

variable "databases_created" {
  description = "List of all databases Created by postgres provider!!!"
  type        = list(string)
  default     = []
}


variable "schemas_list_owners" {
  description = <<-EOT
  If a schemas in this map does not also exist in the onwers list, it will be ignored.
  Example usage of schemas:
  ```schemas = [
    {
      database   = "postgres"
      name_of_theschema = "EXAMPLE_PUBLIC"
      onwer = "EXAMPLE_POSTGRES"
      policy {
        usage = true/false # yes to grant usage on schema
        role = "ROLE/USER" # The role/user to which this schema would be granted access to
      }
        # app_releng can create new objects in the schema.  This is the role that
         # migrations are executed as.
      policy {
      with_create_object = true/false
      with_usage = true/false
      role_name  = "postgres" if false null
  }
      ]```
  Note: An empty objects list applies the privilege on all database objects matching the type provided.
  For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html
  EOT
  type = list(object({
    database           = string
    name_of_theschema  = string
    onwer              = string
    usage              = bool
    role               = string
    with_create_object = bool
    with_usage         = bool
    role_name          = string
  }))
  default = []
}



variable "db_users_privileges" {
  description = <<-EOT
  If a user in this map does not also exist in the db_users list, it will be ignored.
  Example usage of db_users:
  ```db_users_privileges = [
    {
      database  = "EXAMPLE POSTGRES"
      user       = “example_user1"
      type  = “example_type1”
      schema     = "example_schema1"
      privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
      objects    = [“example_object”]
    },
    {
      database  = "EXAMPLE POSTGRES"
      user       = “example_user2"
      type       = “example_type2”
      schema     = “example_schema2"
      privileges = [“SELECT”]
      objects    = []
    }
  ]```
  Note: An empty objects list applies the privilege on all database objects matching the type provided.
  For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html
  EOT
  type = list(object({
    user       = string
    type       = string
    schema     = string
    privileges = list(string)
    objects    = list(string)
    database   = string
  }))
  default = []
}
