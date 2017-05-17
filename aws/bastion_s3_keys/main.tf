resource "aws_security_group" "bastion" {
    name        = "${var.name}.sg.bastion"
    vpc_id      = "${var.vpc_id}"
    description = "Bastion security group"

    tags      { Name = "${var.name}" }
    lifecycle { create_before_destroy = true }

    ingress {
        protocol    = -1
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = -1
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

module "ami" {
    source        = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
    instance_type = "${var.instance_type}"
    region        = "${var.region}"
    distribution  = "trusty"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/${var.user_data_file}")}"

  vars {
    s3_bucket_name              = "${var.s3_bucket_name}"
    s3_bucket_uri               = "${var.s3_bucket_uri}"
    ssh_user                    = "${var.ssh_user}"
    keys_update_frequency       = "${var.keys_update_frequency}"
    enable_hourly_cron_updates  = "${var.enable_hourly_cron_updates}"
    additional_user_data_script = "${var.additional_user_data_script}"
  }
}

resource "aws_instance" "bastion" {
    ami                    = "${module.ami.ami_id}"
    instance_type          = "${var.instance_type}"
    subnet_id              = "${element(var.subnet_ids, count.index)}"
    key_name               = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
    associate_public_ip_address = true
    //  iam_instance_profile   = "${var.iam_instance_profile}"
    //  user_data              = "${template_file.user_data.rendered}"

    tags      { Name = "${var.name}" }
    lifecycle { create_before_destroy = true }
}
