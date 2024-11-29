# install-TFE-with-podman

## What is this guide about?

Use this guide to spawn an AWS EC2 instance with operating system RHEL 9.4, Terraform Enterprise FDO Podman with operational type disk with let’s encrypt certificates.

## Prerequisites 

- Account on AWS Cloud

- AWS IAM user with permissions to use AWS EC2 and AWS Route53

- AWS cli installed and configured

- SSH key pair on AWS 

- A DNS zone hosted on AWS Route53

- Terraform Enterprise Podman license

- Git installed and configured on your computer

- Terraform installed on your computer

## Create the AWS resources and start TFE


To clone the repository to your computer, open your cli and run:
```
git clone git@github.com:StamatisChr/install-TFE-with-podman.git
```


When the repository cloning is finished, change directory to the repo’s terraform directory:
```
cd install-TFE-with-podman
```

Here you need to create a `variables.auto.tfvars` file with your specifications. Use the example tfvars file.

Rename the example file:
```
mv variables.auto.tfvars.example variables.auto.tfvars
```
Edit the file:
```
vim variables.auto.tfvars
```

To populate the file according to the file comments and save.

Initialize terraform, run:
```
terraform init
```

Create the resources with terraform, run:
```
terraform apply
```
review the terraform plan.

Type yes when prompted with:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```
Wait until you see the apply completed message and the output values. 
Example:
```
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

aws_region = "eu-west-1"
connect_to_ec2_via_ssh = "ssh ec2-user@ec2-34-242-219-220.eu-west-1.compute.amazonaws.com"
first_user_instructions = <<EOT
## How to create initial admin user

Wait 7-8 minutes after the terraform apply.
Then run the commands bellow and visit the URL to setup the admin user.

export TFETOKEN=$(ssh ec2-user@tfe-podman-sole.stamatios-chrysinas.sbx.hashidemos.io sudo podman exec -it terraform-enterprise-terraform-enterprise tfectl admin token)
echo "https://tfe-podman-sole.stamatios-chrysinas.sbx.hashidemos.io/admin/account/new?token=$TFETOKEN"


EOT
rhel9_ami_id = "ami-0c44debc472ede5ff"
rhel9_ami_name = "RHEL-9.4.0_HVM-20241114-x86_64-0-Hourly2-GP3"
tfe-podman-fqdn = "tfe-podman-sole.stamatios-chrysinas.sbx.hashidemos.io"
```


Wait about 7-8 minutes for Terraform Enterprise to initialize.

Use the commands from the output with name `first_user_instructions` to set up your first admin user.

Visit the official documentation to learn more about Terraform Enterprise application administration:
https://developer.hashicorp.com/terraform/enterprise/application-administration/general

## Clean up

To delete all the resources, run:
```
terraform destroy
```
type yes when prompted.

Wait for the resource deletion.
```
Destroy complete! Resources: 9 destroyed.
```

Done.