output "public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.server.public_ip
}

output "dashboard_url" {
  description = "Where the dashboard will be"
  value       = "http://${aws_instance.server.public_ip}:8000"
}

output "ssh_command" {
  description = "Command to log in"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.server.public_ip}"
}
