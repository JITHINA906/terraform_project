
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.my_instance.id
}

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.my_instance.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.my_instance.public_dns
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  value       = aws_instance.my_instance.ami
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.my_security_group.id
}
