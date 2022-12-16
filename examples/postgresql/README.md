# PostgreSQL Example

Configuration in this directory creates a PostgreSQL Aurora cluster.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
# Usage
```hcl
module "aurora" {
  source = "../../"

  component_name = var.component_name
  slack_token         = jsondecode(local.operational_state.secrets_version.slacktoken)["slacktoken"]
  name           = local.name
  engine         = "aurora-postgresql"
  engine_version = "11.12"
   instances = {
    1 = {
      instance_class      = "db.r5.2xlarge"
      publicly_accessible = false
    }
  }

  vpc_id                 = local.vpc_id
  db_subnet_group_name   = local.db_subnets_names
  create_db_subnet_group = false
  allowed_cidr_blocks    = compact(concat(local.private_sunbet_cidrs, data.terraform_remote_state.operational_shared.outputs.private_subnets_cidrs))
  subnets                = local.private_subnets_ids

  create_security_group = true
  security_group_egress_rules = {
    to_cidrs = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Egress to corporate printer closet"
    }
  }
  iam_database_authentication_enabled = true
  apply_immediately   = true
  skip_final_snapshot = true

  enabled_cloudwatch_logs_exports = ["postgresql"]
  database_name                   = "postgres_aurora"
  master_username                 = var.master_username
  db_users                        = var.db_users
}

```
Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=v1.2.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.18.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora"></a> [aurora](#module\_aurora) | ../../ | n/a |
| <a name="module_required_tags"></a> [required\_tags](#module\_required\_tags) | git::https://github.com/Bkoji1150/kojitechs-tf-aws-required-tags.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ssm_fleet_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.jumber_sever](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.jumber_sever](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [terraform_remote_state.operational_environment](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado"></a> [ado](#input\_ado) | Compainy name for this project | `string` | `"Kojitechs"` | no |
| <a name="input_application"></a> [application](#input\_application) | Logical name for the application. Mainly used for kojitechs. For an ADO/LOB owned application default to the LOB name. | `string` | `"test-postgres"` | no |
| <a name="input_application_owner"></a> [application\_owner](#input\_application\_owner) | Email Group for the Application owner. | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Environment this template would be deployed to | `map(string)` | n/a | yes |
| <a name="input_builder"></a> [builder](#input\_builder) | Email for the builder of this infrastructure | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_cell_name"></a> [cell\_name](#input\_cell\_name) | Name of the ECS cluster to deploy the service into. | `string` | `"APP"` | no |
| <a name="input_component_name"></a> [component\_name](#input\_component\_name) | Name of the component. | `string` | `"hqr-common-database"` | no |
| <a name="input_databases_created"></a> [databases\_created](#input\_databases\_created) | List of all databases Created by postgres provider!!! | `list(string)` | `[]` | no |
| <a name="input_db_users"></a> [db\_users](#input\_db\_users) | List of all databases | `list(any)` | `[]` | no |
| <a name="input_db_users_privileges"></a> [db\_users\_privileges](#input\_db\_users\_privileges) | If a user in this map does not also exist in the db\_users list, it will be ignored.<br>Example usage of db\_users:<pre>db_users_privileges = [<br>  {<br>    database  = "EXAMPLE POSTGRES"<br>    user       = “example_user1"<br>    type  = “example_type1”<br>    schema     = "example_schema1"<br>    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]<br>    objects    = [“example_object”]<br>  },<br>  {<br>    database  = "EXAMPLE POSTGRES"<br>    user       = “example_user2"<br>    type       = “example_type2”<br>    schema     = “example_schema2"<br>    privileges = [“SELECT”]<br>    objects    = []<br>  }<br>]</pre>Note: An empty objects list applies the privilege on all database objects matching the type provided.<br>For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html | <pre>list(object({<br>    user       = string<br>    type       = string<br>    schema     = string<br>    privileges = list(string)<br>    objects    = list(string)<br>    database   = string<br>  }))</pre> | `[]` | no |
| <a name="input_line_of_business"></a> [line\_of\_business](#input\_line\_of\_business) | HIDS LOB that owns the resource. | `string` | `"TECH"` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user | `string` | `"postgres"` | no |
| <a name="input_schemas_list_owners"></a> [schemas\_list\_owners](#input\_schemas\_list\_owners) | If a schemas in this map does not also exist in the onwers list, it will be ignored.<br>Example usage of schemas:<pre>schemas = [<br>  {<br>    database   = "postgres"<br>    name_of_theschema = "EXAMPLE_PUBLIC"<br>    onwer = "EXAMPLE_POSTGRES"<br>    policy {<br>      usage = true/false # yes to grant usage on schema<br>      role = "ROLE/USER" # The role/user to which this schema would be granted access to<br>    }<br>      # app_releng can create new objects in the schema.  This is the role that<br>       # migrations are executed as.<br>    policy {<br>    with_create_object = true/false<br>    with_usage = true/false<br>    role_name  = "postgres" if false null<br>}<br>    ]</pre>Note: An empty objects list applies the privilege on all database objects matching the type provided.<br>For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html | <pre>list(object({<br>    database           = string<br>    name_of_theschema  = string<br>    onwer              = string<br>    usage              = bool<br>    role               = string<br>    with_create_object = bool<br>    with_usage         = bool<br>    role_name          = string<br>  }))</pre> | `[]` | no |
| <a name="input_tech_poc_primary"></a> [tech\_poc\_primary](#input\_tech\_poc\_primary) | Primary Point of Contact for Technical support for this service. | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Canonical name of the application tier | `string` | `"DATA"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The VPC the resource resides in. We need this to differentiate from Lifecycle Environment due to INFRA and SEC. One of "APP", "INFRA", "SEC", "ROUTING". | `string` | `"APP"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_cluster_endpoints"></a> [additional\_cluster\_endpoints](#output\_additional\_cluster\_endpoints) | A map of additional cluster endpoints and their attributes |
| <a name="output_aws_secrets_version"></a> [aws\_secrets\_version](#output\_aws\_secrets\_version) | n/a |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_cluster_database_name"></a> [cluster\_database\_name](#output\_cluster\_database\_name) | Name for an automatically created database on cluster creation |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Writer endpoint for the cluster |
| <a name="output_cluster_engine_version_actual"></a> [cluster\_engine\_version\_actual](#output\_cluster\_engine\_version\_actual) | The running version of the cluster database |
| <a name="output_cluster_hosted_zone_id"></a> [cluster\_hosted\_zone\_id](#output\_cluster\_hosted\_zone\_id) | The Route53 Hosted Zone ID of the endpoint |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The RDS Cluster Identifier |
| <a name="output_cluster_instances"></a> [cluster\_instances](#output\_cluster\_instances) | A map of cluster instances and their attributes |
| <a name="output_cluster_master_password"></a> [cluster\_master\_password](#output\_cluster\_master\_password) | The database master password |
| <a name="output_cluster_master_username"></a> [cluster\_master\_username](#output\_cluster\_master\_username) | The database master username |
| <a name="output_cluster_members"></a> [cluster\_members](#output\_cluster\_members) | List of RDS Instances that are a part of this cluster |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The database port |
| <a name="output_cluster_reader_endpoint"></a> [cluster\_reader\_endpoint](#output\_cluster\_reader\_endpoint) | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_cluster_role_associations"></a> [cluster\_role\_associations](#output\_cluster\_role\_associations) | A map of IAM roles associated with the cluster and their attributes |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | The db subnet group name |
| <a name="output_enhanced_monitoring_iam_role_arn"></a> [enhanced\_monitoring\_iam\_role\_arn](#output\_enhanced\_monitoring\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the enhanced monitoring role |
| <a name="output_enhanced_monitoring_iam_role_name"></a> [enhanced\_monitoring\_iam\_role\_name](#output\_enhanced\_monitoring\_iam\_role\_name) | The name of the enhanced monitoring role |
| <a name="output_enhanced_monitoring_iam_role_unique_id"></a> [enhanced\_monitoring\_iam\_role\_unique\_id](#output\_enhanced\_monitoring\_iam\_role\_unique\_id) | Stable and unique string identifying the enhanced monitoring role |
| <a name="output_users_secrets"></a> [users\_secrets](#output\_users\_secrets) | The security group ID of the cluster |
| <a name="output_users_secrets_version"></a> [users\_secrets\_version](#output\_users\_secrets\_version) | The security group ID of the cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
