variable "aws_region" {
  description = "The AWS region in use to spawn the resources"
  type        = string
}

variable "tfe_instance_type" {
  description = "The ec2 instance typr for TFE"
  type        = string
}

variable "my_key_name" {
  description = "The name of the ssh key pair"
  type        = string
}

variable "my_hosted_zone_name" {
  description = "The zone ID of my doormat hosted route53 zone"
  type        = string
}

variable "my_tfe_dns_record" {
  description = "The dns record of my TFE instance"
  type        = string
}

variable "certificate_email" {
  description = "The email used for the ACME registration"
  type        = string
}