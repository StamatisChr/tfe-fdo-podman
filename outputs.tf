output "rhel9_ami_id" {
  value = data.aws_ami.rhel9-ami-latest.id

}

output "rhel9_ami_name" {
  value = data.aws_ami.rhel9-ami-latest.name

}

output "aws_region" {
  value = var.aws_region

}

output "connect_to_ec2_via_ssh" {
  description = "use the following command to connect to your ec2 instance with SSH."
  value       = "ssh ec2-user@${aws_instance.tfe_podman_instance.public_dns}"
}

output "tfe-podman-fqdn" {
  description = "tfe-fqdn"
  value       = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"

}

output "first_user_instructions" {
  description = "How to get the admin token and setup the first user"
  value = templatefile("./templates/get_admin_token.tftpl", {
    tfe_hostname = "${var.tfe_dns_record}-${random_pet.hostname_suffix.id}.${var.hosted_zone_name}"
  })

}