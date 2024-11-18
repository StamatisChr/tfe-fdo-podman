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
  value       = "Wait a few minutes. Then use this command to connect with ssh \n ssh ubuntu@${aws_instance.tfe_instance.public_dns}"
}


