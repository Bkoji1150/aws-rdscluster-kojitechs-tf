aws_account_id = {
  prod = "735972722491"
}

db_users = [
  "kojitechs",
  "api",
  "readonly",
  "readwrite",
]

databases_created = [
  "kojitechkart",
  "api",
]

schemas_list_owners = [
  {
    database           = "kojitechkart"
    name_of_theschema  = "kojitechkart"
    onwer              = "kojitechs"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "kojitechs"
  }
]

db_users_privileges = [
  {
    database   = "kojitechkart"
    privileges = ["USAGE"]
    schema     = "kojitechkart"
    type       = "schema"
    user       = "kojitechs"
    objects    = []
  },
  {
    database   = "kojitechkart"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "kojitechkart"
    type       = "table"
    user       = "kojitechs"
    objects    = [""]
  },
]
