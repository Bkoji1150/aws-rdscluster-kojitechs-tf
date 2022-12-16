aws_account_id = {
  prod = "735972722491"
}

db_users = [
  "kojitechs",
]

# databases_created = [
#   "kojitechkart",
#   "api",
# ]

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
  },
  {
    database           = "postgres_aurora"
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
    database   = "postgres_aurora"
    privileges = ["USAGE"]
    schema     = "public"
    type       = "schema"
    user       = "kojitechs"
    objects    = []
  },
  {
    database   = "postgres_aurora"
    privileges = ["USAGE"]
    schema     = "kojitechkart"
    type       = "schema"
    user       = "kojitechs"
    objects    = []
  },
  {
    database   = "postgres_aurora"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "public"
    type       = "table"
    user       = "kojitechs"
    objects    = []
  },
]
