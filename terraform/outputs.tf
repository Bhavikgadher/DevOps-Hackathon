output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.skillpulse_ec2.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.skillpulse_ec2.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i <path-to-your-key.pem> ubuntu@${aws_instance.skillpulse_ec2.public_ip}"
}
