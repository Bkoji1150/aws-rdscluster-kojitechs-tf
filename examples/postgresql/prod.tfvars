aws_account_id = {
  prod = "735972722491"
}

db_users = [
  "kojitechs",
  "sonarqube",
  "readonly",
]

databases_created = [
  "kojitechkart",
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
  },
]

db_users_privileges = [
  {
    database   = "sonar"
    privileges = ["USAGE"]
    schema     = "sonarqube"
    type       = "schema"
    user       = "readonly"
    objects    = []
  },

  {
    database   = "sonar"
    privileges = ["SELECT"]
    schema     = "sonarqube"
    type       = "table"
    user       = "readonly"
    objects    = ["users"]
  },
]
