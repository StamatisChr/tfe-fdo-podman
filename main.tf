
## random pet name to make the TFE fqdn change in every deployment 
resource "random_pet" "hostname_suffix" {
  length = 1
}


##### EC2 instance #####
# create ec2 instance
resource "aws_instance" "tfe_podman_instance" {
  ami             = data.aws_ami.rhel9-ami-latest.id
  instance_type   = var.tfe_instance_type
  key_name        = var.my_key_name # the key is region specific
  security_groups = [aws_security_group.tfe_podman_sg.name]

  user_data = templatefile("./templates/user_data_script.tftpl", {
    tfe_host_path_to_certificates = var.tfe_host_path_to_certificates
    tfe_host_path_to_data         = var.tfe_host_path_to_data
    tfe_license                   = var.tfe_license
    tfe_version_image             = var.tfe_version_image
    tfe_hostname                  = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
    tfe_http_port                 = var.tfe_http_port
    tfe_https_port                = var.tfe_https_port
    tfe_encryption_password       = var.tfe_encryption_password
    cert                          = var.lets_encrypt_cert
    bundle                        = var.lets_encrypt_cert
    key                           = var.lets_encrypt_key
  })

  ebs_optimized = true
  root_block_device {
    volume_size = 120
    volume_type = "gp3"

  }

  tags = {
    Name        = "stam-tfe-podman-instance"
    Environment = "stam-podman"
  }
}

#### EC2 security group ######
# Security group for TFE Podman. Ports needed: https://developer.hashicorp.com/terraform/enterprise/deploy/configuration/network
resource "aws_security_group" "tfe_podman_sg" {
  name        = "tfe_podman_sg"
  description = "Allow inbound traffic and outbound traffic for TFE"

  tags = {
    Name        = "tfe_podman_sg"
    Environment = "stam-podman"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_ipv4" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

####### DNS ########
#DNS record, points to ec2 instance public ip. Later an elastic IP should be added. 
resource "aws_route53_record" "tfe-a-record" {
  zone_id = data.aws_route53_zone.my_aws_dns_zone.id
  name    = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 120
  records = [aws_instance.tfe_podman_instance.public_ip]
}
