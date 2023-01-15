aws_account_id = {
  shared = "181437319056"
}

db_users = [
  "kojitechs",
  "sonarqube",
  "ecs-user",
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
