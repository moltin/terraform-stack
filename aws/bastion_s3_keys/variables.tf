variable "name"              { default = "bastion" }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "region"            { }
variable "subnet_ids" { default = [] }
variable "key_name"          { default = "" }
variable "instance_type"     { }




variable "iam_instance_profile" {default = "" }
variable "user_data_file" { default = "user_data.sh" }
variable "s3_bucket_name" { }
variable "s3_bucket_uri" { default = "" }
variable "ssh_user" { default = "ubuntu" }
variable "enable_hourly_cron_updates" { default = "false" }
variable "keys_update_frequency" { default = "" }
variable "additional_user_data_script" { default = "" }
variable "security_group_ids" {
  description = "Comma seperated list of security groups to apply to the bastion."
  default     = ""
}
variable "eip" { default = "" }
variable "associate_public_ip_address" { default = false }
