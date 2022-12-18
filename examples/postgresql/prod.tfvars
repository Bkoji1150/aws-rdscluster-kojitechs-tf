aws_account_id = {
  prod = "735972722491"
}

db_users = [
  "sonarqube",
  "kojitechs",
  "readonly"
]

databases_created = [
  "sonar",
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
  },
  {
    database           = "sonar"
    name_of_theschema  = "sonarqube"
    onwer              = "sonarqube"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "sonarqube"
  }
]

# db_users_privileges = [
#   # {
#   #   database   = "kojitechkart"
#   #   privileges = ["USAGE"]
#   #   schema     = "public"
#   #   type       = "schema"
#   #   user       = "kojitechs"
#   #   objects    = []
#   # },
#   # {
#   #   database   = "kojitechkart"
#   #   privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
#   #   schema     = "public"
#   #   type       = "table"
#   #   user       = "kojitechs"
#   #   objects    = []
#   # },
# ]
