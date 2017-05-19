/**
 * RDS DB Cluster module that will create:
 *
 * - [AWS RDS Cluster](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html)
 * - [AWS RDS Cluster Instance](https://www.terraform.io/docs/providers/aws/r/rds_cluster_instance.html)
 * - [AWS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
 * - [AWS Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html) to allow access to the DB port from other security groups
 *
 * This module offer us a RDS DB Cluster
 */

variable "backup_retention_period" {
    description = "The backup retention period"
}

variable "database_name" {
    description = " The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating"
}

variable "environment" {
    default = "production"
    description = "The environment where we are building the resource"
}

variable "final_snapshot_identifier" {
    description = "The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made"
}

// A list of security groups to allow access to the ingress rule on the RDS
// cluster instance security group
variable "ingress_allow_security_groups" {
    type = "list"
}

variable "instance_class" {
    default = "db.r3.large"
}

variable "master_password" {
    description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
}

variable "master_username" {
    description = "Username for the master DB user"
}

variable "name" {
    description = "The prefix name for all resources"
}

variable "port" {
    default = 3306
    description = "The port on which the DB accepts connections"
}

variable "preferred_backup_window" {
    description = "The time window on which backups will be made (HH:mm-HH:mm)"
}

variable "preferred_maintenance_window" {
    description = "The weekly time range during which system maintenance can occur, in (UTC) e.g. wed:04:00-wed:04:30"
}

variable "rds_cluster_instance_count" {
    default  = 2
    description = "The number of instances to create"
}

// Determines whether a final DB snapshot is created before the DB cluster is
// deleted. If true is specified, no DB snapshot is created. If false is specified,
// a DB snapshot is created before the DB cluster is deleted, using the value
// from final_snapshot_identifier, by default it's `true`.
//
// There is actually an issue with this option that won't allow you to destroy
// your RDS cluster unless you specified `final_snapshot_identifier`, see more
// here [Terraform ignores skip_final_snapshot so it's impossible to delete rds db instance](https://github.com/hashicorp/terraform/issues/5417)
variable "skip_final_snapshot" {
    default = true
}

variable "subnet_ids" {
    type = "list"
    description = "A list of subnet IDs to place in the DB cluster"
}

variable "vpc_id" {
    description = "The VPC ID to create in"
}

module "rds_cluster" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/rds/rds_cluster?ref=0.1.11"

    name                         = "${var.name}"
    database_name                = "${var.database_name}"
    master_username              = "${var.master_username}"
    master_password              = "${var.master_password}"
    skip_final_snapshot          = "${var.skip_final_snapshot}"
    db_subnet_group_name         = "${module.db_subnet_group.id}"
    vpc_security_group_ids       = "${module.sg_rds.id}"
    backup_retention_period      = "${var.backup_retention_period}"
    preferred_backup_window      = "${var.preferred_backup_window}"
    final_snapshot_identifier    = "${var.final_snapshot_identifier}"
    preferred_maintenance_window = "${var.preferred_maintenance_window}"
}

module "rds_cluster_instance" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/rds/rds_cluster_instance?ref=0.1.11"

    name                       = "${var.name}"
    instance_class             = "${var.instance_class}"
    cluster_identifier         = "${module.rds_cluster.cluster_identifier}"
    db_subnet_group_name       = "${module.db_subnet_group.id}"
    rds_cluster_instance_count = "${var.rds_cluster_instance_count}"
}

module "db_subnet_group" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/rds/db_subnet_group?ref=0.1.11"

    name       = "${var.name}"
    subnet_ids = "${var.subnet_ids}"

    tags {
        "Cluster"     = "rds"
        "Audience"    = "private"
        "Environment" = "${var.environment}"
    }
}

module "sg_rds" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/networking/security_group/sg_rds_cluster_instance?ref=0.1.11"

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

// The DNS address of the RDS instance
output "endpoint" { value = "${module.rds_cluster.endpoint}" }

// The port on which the DB accepts connections
output "port" { value = "${module.rds_cluster.port}" }
