output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.portfolio_eip.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_eip.portfolio_eip.public_dns
}

output "website_url" {
  description = "URL to access the portfolio website"
  value       = "http://${aws_eip.portfolio_eip.public_ip}"
}

output "domain_setup_instructions" {
  description = "Instructions for setting up your domain"
  value       = "Add an A record in IONOS DNS: jodiecoleman.co.uk -> ${aws_eip.portfolio_eip.public_ip}"
}

output "health_check_url" {
  description = "URL for health check endpoint"
  value       = "http://${aws_eip.portfolio_eip.public_ip}/health"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_eip.portfolio_eip.public_ip}"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.portfolio_server.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.portfolio_sg.id
}