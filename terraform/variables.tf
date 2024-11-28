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

variable "hosted_zone_name" {
  description = "The zone ID of my doormat hosted route53 zone"
  type        = string
}

variable "tfe_dns_record" {
  description = "The dns record of my TFE instance"
  type        = string
}

####

variable "tfe_operational_mode" {
  description = "TFE operational mode, it could be disk, external, active-active"
  type        = string
}

variable "tfe_license" {
  description = "your TFE license string"
  type        = string
}

variable "tfe_http_port" {
  description = "TFE container http port"
  type        = number
}

variable "tfe_https_port" {
  description = "TFE container https port"
  type        = number
}

variable "tfe_encryption_password" {
  description = "TFE encryption password"
  type        = string
}

variable "tfe_version_image" {
  description = "The desired TFE version, example value: v202410-1"
  type        = string
}

variable "tfe_host_path_to_certificates" {
  description = "The path on the host machine to store the certificate files"
  type        = string
}

variable "tfe_host_path_to_data" {
  description = "The path on the host machine to store tfe data"
  type        = string
}

variable "lets_encrypt_cert" {
  description = "value"
  type        = string

}

variable "lets_encrypt_key" {
  description = "value"
  type        = string
}