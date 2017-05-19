/**
 * Bastion module that will create:
 *
 * - [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
 * - [AWS Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html) to allow access to the DB port from other security groups
 *
 * This module offer us a bastion server that will be deployed to our public subnets and will act as a bridge giving us access to instances deployed to our private subnet
 *
 * If you ever need to access an instance directly, you can do it by `tunneling` through the bastion instance.
 *
 *    $ ssh -i <path/to/key> ubuntu@<bastion-ip> ssh ubuntu@<internal-ip>
 */

variable "environment" {
    default = "production"
    description = "The environment where we are building the resource"
}

variable "name" {
    description = "The prefix name for all resources"
}

variable "subnet_ids" {
    type = "list"
    description = "A list of subnet IDs to place in the DB cluster"
}

variable "vpc_id" {
    description = "The VPC ID to create in"
}

variable "vpc_cidr" {
    default = ["0.0.0.0/0"]
    description = "The cidr block of the desired VPC"
}

variable "key_name" {
    description = "The name of the SSH key to use on the instance, e.g. moltin"
}

variable "instance_count" {
    default = 1
    description = "The number of instances to create"
}

variable "instance_type" {
    default = "t2.small"
    description = "The type of instance to start"
}

variable "distribution" {
    default = "trusty"
    description = "Ubuntu distribution to be installed"
}

variable "vpc_security_group_ids" {
    type = "list"
    description = "A list of security group IDs to associate with"
}

resource "aws_instance" "bastion" {
    count = "${var.instance_count}"

    ami                    = "${module.ami.id}"
    key_name               = "${var.key_name}"
    subnet_id              = "${element(sort(var.subnet_ids), count.index)}"
    instance_type          = "${var.instance_type}"
    vpc_security_group_ids = ["${module.sg_ssh.id}", "${var.vpc_security_group_ids}"]

    associate_public_ip_address = true

    root_block_device {
        volume_size           = 16
        delete_on_termination = true
    }

    lifecycle {
        ignore_changes = ["ami"]
    }

    tags {
        "Name"        = "${format("%s-bastion-ec2-instance-%03d", var.name, count.index)}"
        "Cluster"     = "security"
        "Role"        = "bastion"
        "Audience"    = "public"
        "Terraform"   = "true"
        "Environment" = "${var.environment}"
    }
}

module "sg_ssh" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/networking/security_group/sg_ssh?ref=0.1.11"

    name     = "${var.name}"
    vpc_id   = "${var.vpc_id}"
    vpc_cidr = "${var.vpc_cidr}"

    tags {
        "Cluster"     = "security"
        "Audience"    = "public"
        "Environment" = "${var.environment}"
    }
}

module "ami" {
    source = "git::ssh://git@github.com/moltin/terraform-modules.git//aws/data/ubuntu_ami?ref=0.1.11"

    distribution = "${var.distribution}"
}

// User to access bastion
output "user" { value = "ubuntu" }

// Private IP address to associate with the instance in a VPC
output "private_ip" { value = "${aws_instance.bastion.private_ip}" }

// The public IP address assigned to the instance
output "public_ip"  { value = "${aws_instance.bastion.public_ip}" }
