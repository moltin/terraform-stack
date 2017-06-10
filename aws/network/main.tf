/**
 * Network module that will create:
 *
 * - [AWS VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
 * - [AWS Public Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
 * - [AWS Private Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
 * - [AWS NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
 * - [AWS Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
 *
 * This module offer us the basic network infrastructure to build our system
 */

variable "environment" {
    default = "production"
    description = "The environment where we are building the resource"
}

variable "name" {
    description = "The prefix name for all resources"
}

variable "private_subnet_azs" {
    type = "list"
    description = "A list of availability zones to place in the private subnets"
}

variable "private_subnet_cidrs" {
    type = "list"
    description = "A list of private subnet cidr block"
}

variable "public_subnet_azs" {
    type = "list"
    description = "A list of availability zones to place in the public subnets"
}

variable "public_subnet_cidrs" {
    type = "list"
    description = "A list of public subnet cidr block"
}

variable "vpc_cidr" {
    default = "The cidr block of the desired VPC"
}

module "vpc" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/networking/vpc?ref=0.2.0"

    name                 = "${var.name}"
    cidr                 = "${var.vpc_cidr}"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags {
      Role        = "virtual private cloud"
      Cluster     = "network"
      Audience    = "public"
      Environment = "${var.environment}"
    }
}

module "igw" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/networking/internet_gateway?ref=0.2.0"

    name   = "${var.name}"
    vpc_id = "${module.vpc.id}"

    tags {
        Role        = "internet gateway"
        Cluster     = "network"
        Audience    = "public"
        Environment = "${var.environment}"
    }
}

module "public_subnet" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/networking/public_subnet?ref=0.2.0"

    name                    = "${var.name}"
    vpc_id                  = "${module.vpc.id}"
    gateway_id              = "${module.igw.id}"
    cidr_blocks             = "${var.public_subnet_cidrs}"
    availability_zones      = "${var.public_subnet_azs}"
    map_public_ip_on_launch = true

    tags {
        Role        = "public subnet"
        Cluster     = "network"
        Audience    = "public"
        Environment = "${var.environment}"
    }
}

module "private_subnet" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/networking/private_subnet?ref=0.2.0"

    name               = "${var.name}"
    vpc_id             = "${module.vpc.id}"
    cidr_blocks        = "${var.private_subnet_cidrs}"
    public_subnet_ids  = ["${module.public_subnet.ids}"]
    nat_gateway_count  = "${length(var.public_subnet_cidrs)}"
    availability_zones = "${var.private_subnet_azs}"

    tags {
        Role        = "private subnet"
        Cluster     = "network"
        Audience    = "private"
        Environment = "${var.environment}"
    }
}

// A list of private subnet IDs
output "private_subnet_ids" { value = "${module.private_subnet.ids}" }

// A list of public subnet IDs
output "public_subnet_ids" { value = "${module.public_subnet.ids}" }

// The ID of the VPC
output "vpc_id" { value = "${module.vpc.id}" }
