terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

