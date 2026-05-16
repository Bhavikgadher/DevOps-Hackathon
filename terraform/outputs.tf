output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.skillpulse_ec2.public_ip
}
