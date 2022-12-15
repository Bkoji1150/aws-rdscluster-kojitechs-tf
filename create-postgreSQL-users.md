Using terraform postgresql provider, we can create database objects like `users`, `tables`, `schemas` and most importantly manage user privileges at fine grained level (`userprivileges`)
[postgres uril](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs)

## Create database users 
In this project when a user is created, aws secrets manager resource is also created with the user password and database password
*.tfvars
[![Image](https://drive.google.com/file/d/1dX66DbgUI1y9Wez_joYshBmVu4kS6iJv/view?usp=sharing "Terraform on AWS with SRE & IaC DevOps | Real-World 20 Demos")](https://drive.google.com/file/d/1dX66DbgUI1y9Wez_joYshBmVu4kS6iJv/view?usp=sharing)
pics:

```hcl
db_users = [
  "kojitechs"
]
```

## Create database
Create a database in postgres rds instance
```hcl
databases_created = [
  "kojitechkart",
]
```

## Create database schema 
Create a schema in postgres rds instance
```hcl
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
```
## Grant read only access to schema 
In database it's important to fine-grained access to the schema using the policy of least privilege
```hcl
db_users_privileges = [
    {
        database   = "kojitechkart"
        privileges = ["SELECT"]
        schema     = "kojitech"
        type       = "table"
        user       = "kojitechs"
        objects    = []
   },
]   
```
## Grant read/write  access to schema to user
Grant `read/write` access to the schema using the policy of least privilege: 
In the database there's table in public schema call `products`. Here we are granting `read/write` access on table `products` to user `kojitechs`

```hcl
db_users_privileges = [
    {
    database   = "kojitechkart"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "public"
    type       = "table"
    user       = "kojitechs"
    objects    = ["products"]
    },
]
```
## Grant Usage on schema
```hcl
db_users_privileges = [
  {
    database   = "api"
    privileges = ["USAGE"]
    schema     = "kojitech"
    type       = "schema"
    user       = "kojitechs"
    objects    = []
  },
]
```
## SET SEARCH PATH:
```sql
 SET search_path TO kojitechkart;   
```
