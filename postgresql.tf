
provider "postgresql" {

  alias            = "pgconnect"
  host             = try(aws_rds_cluster.this[0].endpoint, "")
  port             = var.port
  username         = var.master_username
  password         = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  superuser        = false
  sslmode          = "require"
  expected_version = try(aws_rds_cluster.this[0].engine_version_actual, "")
  connect_timeout  = 15
}

resource "postgresql_database" "postgres" {

  for_each          = var.engine == "aurora-postgresql"  ? toset(var.databases_created) : []
  provider          = postgresql.pgconnect
  name              = each.key
  allow_connections = true
  depends_on        = [aws_rds_cluster.this]
}

resource "postgresql_schema" "my_schema" {
  for_each = {
    for schema, value in var.schemas_list_owners : schema => value
    if var.engine == "aurora-postgresql"
} 
  provider = postgresql.pgconnect
  name     = each.value.onwer == "database" || each.value.database == "schema" ? null : each.value.name_of_theschema
  owner    = each.value.onwer
  database = contains(var.databases_created, each.value.database) ? each.value.database : "postgres"
  policy {
    usage = each.value.usage
    role  = each.value.role
  }

  policy {
    create = each.value.with_create_object
    usage  = each.value.with_usage
    role   = each.value.role_name
  }
  depends_on = [aws_rds_cluster.this, postgresql_database.postgres]

}

resource "postgresql_role" "users" {

  provider   = postgresql.pgconnect
  for_each   =  var.engine == "aurora-postgresql"  ?  toset(var.db_users): []
  name       = each.key
  login      = true
  password   = jsondecode(aws_secretsmanager_secret_version.user_secret_value[each.value].secret_string)["password"]
  depends_on = [aws_rds_cluster.this, postgresql_database.postgres]
}

resource "postgresql_grant" "user_privileges" {
  for_each = {
    for idx, user_privileges in var.db_users_privileges : idx => user_privileges
    if contains(var.db_users, user_privileges.user) &&  var.engine == "aurora-postgresql"
  }

  database    = each.value.database
  provider    = postgresql.pgconnect
  role        = each.value.user
  privileges  = each.value.privileges
  object_type = each.value.type
  schema      = each.value.type == "database" && each.value.schema == "" ? null : each.value.schema
  objects     = each.value.type == "database" || each.value.type == "schema" ? null : each.value.objects
  depends_on  = [postgresql_role.users]
}
