# Terraform Stack

This project contain a group of [Terraform](http://terraform.io) modules that will act as an unit to provide you with the needed resources for your projects.

If you need to build the network infrastructure to run your instances in, you can use the [network](https://github.com/moltin/terraform-stack/tree/master/aws/network) module which will create a VPC, subnets, NAT gateway and internet gateway for you.

> Note: If you are looking for simpler modules that accomplish a single responsibility we built as well [terraform-modules](https://github.com/moltin/terraform-modules)

This project has been highly inspired by the work of others that have decided to share with the community their work, check the [resources](#resources) section for more info.

## Available Modules

* [Bastion](#bastion)
* [Network](#network)
* [RDS Cluster](#rds-cluster)

## Bastion

Bastion module that will create:

- [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
- [AWS Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html) to allow access to the DB port from other security groups

This module offer us a bastion server that will be deployed to our public subnets and will act as a bridge giving us access to instances deployed to our private subnet

If you ever need to access an instance directly, you can do it by `tunneling` through the bastion instance.

   $ ssh -i <path/to/key> ubuntu@<bastion-ip> ssh ubuntu@<internal-ip>


## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| distribution | Ubuntu distribution to be installed | `trusty` | no |
| environment | The environment where we are building the resource | `production` | no |
| instance_count | The number of instances to create | `1` | no |
| instance_type | The type of instance to start | `t2.small` | no |
| key_name | The name of the SSH key to use on the instance, e.g. moltin | - | yes |
| name | The prefix name for all resources | - | yes |
| subnet_ids | A list of subnet IDs to place in the DB cluster | - | yes |
| vpc_cidr | The cidr block of the desired VPC | `<list>` | no |
| vpc_id | The VPC ID to create in | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| private_ip | Private IP address to associate with the instance in a VPC |
| public_ip | The public IP address assigned to the instance |
| user | User to access bastion |

## Network

Network module that will create:

- [AWS VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
- [AWS Private Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
- [AWS Public Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
- [AWS NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
- [AWS Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)

This module offer us the basic network infrastructure to build our system


## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| environment | The environment where we are building the resource | `production` | no |
| name | The prefix name for all resources | - | yes |
| private_subnet_azs | A list of availability zones to place in the private subnets | - | yes |
| private_subnet_cidrs | A list of private subnet cidr block | - | yes |
| public_subnet_azs | A list of availability zones to place in the public subnets | - | yes |
| public_subnet_cidrs | A list of public subnet cidr block | - | yes |
| vpc_cidr |  | `The cidr block of the desired VPC` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_subnet_ids | A list of private subnet IDs |
| public_subnet_ids | A list of public subnet IDs |
| vpc_id | The ID of the VPC |

## RDS Cluster

RDS DB Cluster module that will create:

- [AWS RDS Cluster](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html)
- [AWS RDS Cluster Instance](https://www.terraform.io/docs/providers/aws/r/rds_cluster_instance.html)
- [AWS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
- [AWS Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html) to allow access to the DB port from other security groups

This module offer us a RDS DB Cluster


## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| database_name | The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating | - | yes |
| environment | The environment where we are building the resource | `production` | no |
| ingress_allow_security_groups | A list of security groups to allow access to the ingress rule on the RDS cluster instance security group | - | yes |
| instance_class |  | `db.r3.large` | no |
| master_password | Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file | - | yes |
| master_username | Username for the master DB user | - | yes |
| name | The prefix name for all resources | - | yes |
| port | The port on which the DB accepts connections | `3306` | no |
| rds_cluster_instance_count |  | `2` | no |
| skip_final_snapshot | There is actually an issue with this option that won't allow you to destroy your RDS cluster unless you specified `final_snapshot_identifier`, see more here [Terraform ignores skip_final_snapshot so it's impossible to delete rds db instance](https://github.com/hashicorp/terraform/issues/5417) | `true` | no |
| subnet_ids | A list of subnet IDs to place in the DB cluster | - | yes |
| vpc_id | The VPC ID to create in | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | The DNS address of the RDS instance |
| port | The port on which the DB accepts connections |


# Authors

* **Israel Sotomayor** - *Initial work* - [zot24](https://github.com/zot24)

See also the list of [contributors](https://github.com/moltin/terraform-stack/contributors) who participated in this project.

# License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/moltin/terraform-stack/blob/master/LICENSE) file for details

## Resources

- Articles
  - [The Segment AWS Stack](https://segment.com/blog/the-segment-aws-stack/)
  - [Terraform Modules for Fun and Profit](http://blog.lusis.org/blog/2015/10/12/terraform-modules-for-fun-and-profit/)
  - [How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
  - [Infrastructure Packages](https://blog.gruntwork.io/gruntwork-infrastructure-packages-7434dc77d0b1)
  - [Terraform: Cloud made easy](http://blog.contino.io/terraform-cloud-made-easy-part-one)
  - [Terraform, VPC, and why you want a tfstate file per env](https://charity.wtf/2016/03/30/terraform-vpc-and-why-you-want-a-tfstate-file-per-env/)
  - Rancher HA:
    - [Deploying Rancher HA in production with AWS, Terraform, and RancherOS](https://thisendout.com/2016/12/10/update-deploying-rancher-in-production-aws-terraform-rancheros/)
    - [AWS and Rancher: Building a Resilient Stack](http://rancher.com/aws-rancher-building-resilient-stack)
  
- Non directly related but useful
  - [Practical VPC Design](https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc)

- GitHub repositories
  - [segmentio/terraform-docs](https://github.com/segmentio/terraform-docs)
  - [segmentio/stack](https://github.com/segmentio/stack)
  - [hashicorp/best-practices](https://github.com/hashicorp/best-practices)
  - [terraform-community-modules](https://github.com/terraform-community-modules)
  - [contino/terraform-learn](https://github.com/contino/terraform-learn)
  - [paybyphone/terraform_aws_private_subnet](https://github.com/paybyphone/terraform_aws_private_subnet)
  - Rancher HA:
    - [cloudnautique/terraform-rancher](https://github.com/cloudnautique/terraform-rancher)
    - [nextrevision/terraform-rancher-ha-example](https://github.com/nextrevision/terraform-rancher-ha-example)
    - [codesheppard/terraform-rancher-starter-template](https://github.com/codesheppard/terraform-rancher-starter-template)
