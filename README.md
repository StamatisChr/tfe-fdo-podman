# install-TFE-with-podman

## What is this guide about?

This guide is to have Terraform Enterprise running with Podman on disk mode.
Follow the steps and an EC2 instance will be created, with proper DNS entries and security group, TFE will be installed and once TFE is installed an admin user, a TFE organization and a TFE workspace will be created for you.
The scope of this guide is to be used as an example, it should not be used as is for production purposes.

## Prerequisites

- Account on AWS Cloud

- AWS IAM user with permissions to use AWS EC2 and AWS Route53

- [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [AWS SSM plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) installed and configured on your computer

- A DNS zone hosted on AWS Route53

- Terraform Enterprise FDO license

- Git installed on your computer

- Terraform installed on your computer

## Create the AWS resources and start TFE

Export your AWS access key and secret access key as environment variables:

```sh
export AWS_ACCESS_KEY_ID=<your_access_key_id>
```

```sh
export AWS_SECRET_ACCESS_KEY=<your_secret_key>
```

Clone the repository to your computer.

Open your cli and run:

```sh
git clone git@github.com:StamatisChr/tfe-fdo-podman.git
```

When the repository cloning is finished, change directory to the repo’s terraform directory:

```sh
cd tfe-fdo-podman
```

Here you need to create a `variables.auto.tfvars` file with your specifications. Use the example tfvars file.

Rename the example file:

```sh
cp variables.auto.tfvars.example variables.auto.tfvars
```

Edit the file:

```sh
vim variables.auto.tfvars
```

```sh
# example tfvars file
# do not change the variable names on the left column
# replace only the values in the "< >" placeholders

aws_region                    = "<aws_region>"             # Set here your desired AWS region, example: eu-west-1
tfe_instance_class            = "<aws_ec2_instance_class>" # Set here the EC2 instance class only architecture x86_64 is supported, example: m5.xlarge
db_instance_class             = "<aws_rds_instance_class>" # Set here the RDS instance class, example:  "db.t3.large"
hosted_zone_name              = "<dns_zone_name>"          # your AWS route53 DNS zone name
tfe_dns_record                = "<tfe_host_record>"        # the host record for your TFE instance on your dns zone, example: my-tfe
tfe_license                   = "<tfe_license_string>"     # TFE license string
tfe_encryption_password       = "<type_a_password>"        # TFE encryption password
tfe_version_image             = "<tfe_version>"            # desired TFE version, example: v202410-1
admin_password                = "<type_a_password>"        # The password of the TFE Admin user

```

To populate the file according to the file comments and save.

Initialize terraform, run:

```sh
terraform init
```

Create the resources with terraform, run:

```sh
terraform apply
```

review the terraform plan.

Type yes when prompted with:

```sh
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

Wait until you see the apply completed message and the output values.

Example:

```sh
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

TFE_user_username = "admin"
aws_region = "eu-west-1"
rhel9_ami_id = "ami-02e145cba2d8ae80e"
rhel9_ami_name = "RHEL-9.4.0_HVM-20250218-x86_64-0-Hourly2-GP3"
start_aws_ssm_session = "aws ssm start-session --target i-0d8b5b4764b377159 --region eu-west-1"
tfe-podman-fqdn = "https://tfe-podman-cat.stamatios-chrysinas.sbx.hashidemos.io"
```

Wait about 7-8 minutes for Terraform Enterprise to initialize.

Visit the tfe-podman-fqdn from the output.
To log in, use `admin` as username and the password you set for `admin_password`  as password

## Clean up

To delete all the resources, run:

```sh
terraform destroy
```

type yes when prompted.

Wait for the resource deletion.

```sh
Destroy complete! Resources: 11 destroyed.
```

Done.
