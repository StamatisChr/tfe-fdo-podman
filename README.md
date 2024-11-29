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

Here you need to create a `variables.auto.tfvars` file with your specifications.

Create the file:
```
touch variables.auto.tfvars
```
Edit the file:
```
vim variables.auto.tfvars
```

To populate the file: 

