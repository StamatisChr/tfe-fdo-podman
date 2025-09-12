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


resource "aws_vpc_security_group_ingress_rule" "port_443_https" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# TFE System API port
resource "aws_vpc_security_group_ingress_rule" "port_8446_admin_https" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8446
  ip_protocol       = "tcp"
  to_port           = 8446
}

# Netdata monitoring port
resource "aws_vpc_security_group_ingress_rule" "port_19999_netdata" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 19999
  ip_protocol       = "tcp"
  to_port           = 19999
}


resource "aws_vpc_security_group_ingress_rule" "port_80_http" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic_ipv4" {
  security_group_id = aws_security_group.tfe_podman_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}