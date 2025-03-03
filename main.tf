
## random pet name to make the TFE fqdn change in every deployment 
resource "random_pet" "hostname_suffix" {
  length = 1
}

resource "aws_instance" "tfe_instance" {
  ami                  = data.aws_ami.rhel9-ami-latest.id
  instance_type        = var.tfe_instance_type
  security_groups      = [aws_security_group.tfe_podman_sg.name]
  iam_instance_profile = aws_iam_instance_profile.tfe_ssm_access.name

  user_data = templatefile("./templates/user_data_cloud_init.tftpl", {
    tfe_host_path_to_certificates = var.tfe_host_path_to_certificates
    tfe_host_path_to_data         = var.tfe_host_path_to_data
    tfe_host_path_to_scripts      = var.tfe_host_path_to_scripts
    tfe_license                   = var.tfe_license
    tfe_version_image             = var.tfe_version_image
    tfe_hostname                  = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
    tfe_http_port                 = var.tfe_http_port
    tfe_https_port                = var.tfe_https_port
    tfe_encryption_password       = var.tfe_encryption_password
    cert                          = var.lets_encrypt_cert
    bundle                        = var.lets_encrypt_cert
    key                           = var.lets_encrypt_key
    aws_region                    = var.aws_region
    org_name                      = var.org_name
    workspace_name                = var.workspace_name
    admin_email                   = var.admin_email
    admin_username                = var.admin_username
    admin_password                = var.admin_password
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

resource "aws_eip" "tfe_eip" {
  instance = aws_instance.tfe_instance.id
}

resource "aws_route53_record" "tfe-a-record" {
  zone_id = data.aws_route53_zone.my_aws_dns_zone.id
  name    = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 120
  records = [aws_eip.tfe_eip.public_ip]
}

resource "aws_iam_role" "tfe_ssm_access" {
  name = "tfe_ssm_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name = "stam-${random_pet.hostname_suffix.id}"
  }
}

resource "aws_iam_instance_profile" "tfe_ssm_access" {
  name = "tfe_ssm_access_profile"
  role = aws_iam_role.tfe_ssm_access.name
}

resource "aws_iam_role_policy_attachment" "SSM" {
  role       = aws_iam_role.tfe_ssm_access.name
  policy_arn = data.aws_iam_policy.SecurityComputeAccess.arn
}