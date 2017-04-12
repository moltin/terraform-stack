/**
 * RDS DB Cluster module that will create:
 *
 * - [AWS RDS Cluster](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html)
 * - [AWS RDS Cluster Instance](https://www.terraform.io/docs/providers/aws/r/rds_cluster_instance.html)
 * - [AWS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
 * - [AWS Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html) to allow access to the DB port from other security groups
 *
 * This module offer us the basic network infrastructure to build our system
 */

variable "name" {
    description = "The prefix name for all resources"
}

variable "environment" {
    default = "production"
    description = "The environment where we are building the resource"
}

variable "database_name" {
    description = " The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating"
}

variable "master_password" {
    description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
}

variable "master_username" {
    description = "Username for the master DB user"
}

variable "port" {
    default = 3306
    description = "The port on which the DB accepts connections"
}

variable "public_subnet_ids" {
    type = "list"
    description = "A list of public subnet IDs"
}

variable "vpc_id" {
    description = "The VPC ID to create in"
}

// A list of security groups to allow access to the ingress rule on the RDS cluster instance security group
variable "ingress_allow_security_groups" {
    type = "list"
}

// There is actually an issue with this option that won't allow you to destroy your RDS cluster
// unless you specified `final_snapshot_identifier`, see more here [Terraform ignores skip_final_snapshot so it's impossible to delete rds db instance](https://github.com/hashicorp/terraform/issues/5417)
variable "skip_final_snapshot" {
    default = true
}

variable "rds_cluster_instance_count" {
    default  = 2
}

variable "instance_class" {
    default = "db.r3.large"
}

module "rds_cluster" {
    source = "github.com/moltin/terraform-modules/aws/rds/rds_cluster"

    name                   = "${var.name}"
    database_name          = "${var.database_name}"
    master_username        = "${var.master_username}"
    master_password        = "${var.master_password}"
    skip_final_snapshot    = "${var.skip_final_snapshot}"
    db_subnet_group_name   = "${module.db_subnet_group.id}"
    vpc_security_group_ids = "${module.sg_rds.id}"
}

module "rds_cluster_instance" {
    source = "github.com/moltin/terraform-modules/aws/rds/rds_cluster_instance"

    name                       = "${var.name}"
    instance_class             = "${var.instance_class}"
    cluster_identifier         = "${module.rds_cluster.cluster_identifier}"
    db_subnet_group_name       = "${module.db_subnet_group.id}"
    rds_cluster_instance_count = "${var.rds_cluster_instance_count}"
}

module "db_subnet_group" {
    source = "github.com/moltin/terraform-modules/aws/rds/db_subnet_group"

    name       = "${var.name}"
    subnet_ids = "${var.public_subnet_ids}"

    tags {
        "Cluster"     = "rds"
        "Audience"    = "private"
        "Environment" = "${var.environment}"
    }
}

module "sg_rds" {
    source = "github.com/moltin/terraform-modules/aws/networking/security_group/sg_rds_cluster_instance"

    name   = "${var.name}"
    port   = "${var.port}"
    vpc_id = "${var.vpc_id}"
    ingress_allow_security_groups = "${var.ingress_allow_security_groups}"

    tags {
        "Cluster"     = "rds"
        "Audience"    = "private"
        "Environment" = "${var.environment}"
    }
}

// The port on which the DB accepts connections
output "port" { value = "${module.rds_cluster.port}" }

// The DNS address of the RDS instance
output "endpoint" { value = "${module.rds_cluster.endpoint}" }
