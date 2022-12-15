aws_account_id = {
  sbx = "674293488770"
}

db_users = [
  "kojitechs",
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

# db_users_privileges = [
#   {
#     database   = "api"
#     privileges = ["SELECT"]
#     schema     = "kojitech"
#     type       = "table"
#     user       = "readonly"
#     objects    = []
#   },
#   {
#     database   = "api"
#     privileges = ["USAGE"]
#     schema     = "kojitech"
#     type       = "schema"
#     user       = "readwrite"
#     objects    = []
#   },
# ]
# {
#   database   = "api"
#   privileges = ["SELECT"]
#   schema     = "public"
#   type       = "table"
#   user       = "readonly"
#   objects    = ["products"]
# },
# {
#   database   = "api"
#   privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
#   schema     = "public"
#   type       = "table"
#   user       = "readwrite"
#   objects    = ["products"]
# },
#]
