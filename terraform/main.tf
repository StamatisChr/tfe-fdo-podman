##### EC2 instance #####
# create ec2 instance
resource "aws_instance" "tfe_podman_instance" {
  ami             = data.aws_ami.rhel9-ami-latest.id
  instance_type   = var.tfe_instance_type
  key_name        = var.my_key_name # the key is region specific
  security_groups = [aws_security_group.tfe_podman_sg.name]
  ebs_optimized   = true
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
  name    = var.my_tfe_dns_record
  type    = "A"
  ttl     = 120
  records = [aws_instance.tfe_podman_instance.public_ip]
}


# ###### s3 configuration ######
# # create bucket with unique name
# resource "aws_s3_bucket" "stam-podman-s3" {
#   bucket_prefix = "stam-podman"

#   tags = {
#     Environment = "stam-podman"
#   }
# }

# #block s3 public access
# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = aws_s3_bucket.example.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # set s3 default encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

#https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}