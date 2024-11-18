# Get the latest RHEL 9.4 ami for the region 
data "aws_ami" "rhel9-ami-latest" {
  owners      = ["309956199498"]
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9.4.*_HVM*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_vpc" "my-default" {}

