resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.rsa-4096.private_key_pem
  email_address   = var.certificate_email
}

resource "acme_certificate" "stam_podman" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = var.my_tfe_dns_record

  #https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#using-dns-challenges
  #https://registry.terraform.io/providers/vancluever/acme/latest/docs/guides/dns-providers-route53
  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.my_aws_dns_zone.id
      AWS_DEFAULT_REGION = var.aws_region
    }
  }

  depends_on = [ aws_route53_record.tfe-a-record ]

}

