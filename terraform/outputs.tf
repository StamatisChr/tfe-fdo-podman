output "rhel9_ami_id" {
  value = data.aws_ami.rhel9-ami-latest.id

}

output "rhel9_ami_name" {
  value = data.aws_ami.rhel9-ami-latest.name

}

output "aws_region" {
  value = var.aws_region

}

output "rhel9_ami_description" {
  value = data.aws_ami.rhel9-ami-latest.description

}

output "connect_to_ec2_via_ssh" {
  description = "use the following command to connect to your ec2 instance with SSH."
  value       = "ssh ec2-user@${aws_instance.tfe_podman_instance.public_dns}"
}

output "tfe-podman-fqdn" {
  description = "tfe-fqdn"
  value       = var.my_tfe_dns_record

}

output "see-private-key-test" {
  value     = tls_private_key.rsa-4096.private_key_pem
  sensitive = true

}

output "see-cert-pem-test" {
  value = acme_certificate.stam_podman.certificate_pem

}

output "s3-arn" {
  value = aws_s3_bucket.stam-podman-s3.arn
}