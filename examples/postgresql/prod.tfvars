aws_account_id = {
  prod = "735972722491"
}

db_users = [
  "kojitechs",
  "sonarqube",
  "sonarscannar",
]

databases_created = [
  "kojitechkart",
  "sonar",
  "sonarscannar",
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
  {
    database           = "sonarscannar"
    name_of_theschema  = "sonarscannar"
    onwer              = "sonarscannar"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "sonarscannar"
  },
]
