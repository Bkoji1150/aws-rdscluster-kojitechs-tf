aws_account_id = {
  prod = "735972722491"
}

db_users = [
  "kojitechs",
  "sonarqube",
  "kojitechs-api"
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
  # {
  #   database           = "sonarscannar"
  #   name_of_theschema  = "sonarscannar"
  #   onwer              = "sonarscannar"
  #   usage              = true
  #   role               = null
  #   with_create_object = true
  #   with_usage         = true
  #   role_name          = "sonarscannar"
  # },
  # {
  #   database           = "ecs-db"
  #   name_of_theschema  = "ecs"
  #   onwer              = "ecs-user"
  #   usage              = true
  #   role               = null
  #   with_create_object = true
  #   with_usage         = true
  #   role_name          = "ecs-user"
  # },
]
