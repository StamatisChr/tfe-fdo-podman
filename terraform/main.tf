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

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

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


###### s3 configuration ######
# create bucket with unique name
resource "aws_s3_bucket" "stam-podman-s3" {
  bucket_prefix = "stam-podman-"

  tags = {
    Environment = "stam-podman"
  }
}

#block s3 public access
resource "aws_s3_bucket_public_access_block" "stam-podman-s3" {
  bucket = aws_s3_bucket.stam-podman-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# set s3 default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.stam-podman-s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#create IAM role for the EC2 instance to access the s3 bucket
resource "aws_iam_role" "tfe_podman_instance" {
  name = "tfe_podman_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.tfe_podman_instance.name
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy_to_role" {
  role       = aws_iam_role.tfe_podman_instance.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}


#https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = "./files/key.pem"
}

resource "aws_s3_object" "private_key_pem" {
  bucket = aws_s3_bucket.stam-podman-s3.bucket
  key    = "key.pem"
  source = "./files/key.pem"

  depends_on = [local_file.private_key]

}

resource "local_file" "certificate" {
  content  = acme_certificate.stam_podman.certificate_pem
  filename = "./files/cert.pem"
}

resource "aws_s3_object" "certificate_pem" {
  bucket = aws_s3_bucket.stam-podman-s3.bucket
  key    = "cert.pem"
  source = "./files/cert.pem"

  depends_on = [local_file.certificate]
}

resource "aws_s3_object" "bundle_pem" {
  bucket = aws_s3_bucket.stam-podman-s3.bucket
  key    = "bundle.pem"
  source = "./files/cert.pem"

  depends_on = [local_file.certificate]
}

resource "local_file" "tfe_podman_yml" {
  filename = "./files/deployment.yml"
  content = templatefile("./files/deployment.tftpl", {
    my_tfe_dns_record             = var.my_tfe_dns_record
    tfe_operational_mode          = var.tfe_operational_mode
    tfe_license                   = var.tfe_license
    tfe_http_port                 = var.tfe_http_port
    tfe_https_port                = var.tfe_https_port
    tfe_encryption_password       = var.tfe_encryption_password
    tfe_version_image             = var.tfe_version_image
    tfe_host_path_to_certificates = var.tfe_host_path_to_certificates
    tfe_host_path_to_data         = var.tfe_host_path_to_data

  })
}

resource "aws_s3_object" "tfe_podman_yml" {
  bucket = aws_s3_bucket.stam-podman-s3.bucket
  key    = "deployment.yml"
  source = "./files/deployment.yml"

  depends_on = [local_file.tfe_podman_yml]
}

resource "local_file" "user_data_script" {
  filename = "./files/user-data.sh"
  content = templatefile("./files/user_data_script.tftpl", {
    aws_s3_bucket-stam-podman-s3-bucket = aws_s3_bucket.stam-podman-s3.bucket
    tfe_host_path_to_certificates       = var.tfe_host_path_to_certificates
    tfe_host_path_to_data               = var.tfe_host_path_to_data
    host_path_tfe_files                 = var.host_path_tfe_files
    tfe_license                         = var.tfe_license
    tfe_version_image                   = var.tfe_version_image
  })
}