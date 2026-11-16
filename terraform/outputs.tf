output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.flask_server.id
}

output "public_ip" {
  description = "IP publica de la EC2"
  value       = aws_instance.flask_server.public_ip
}

output "application_url" {
  description = "URL de nuestra API Flask"
  value       = "http://${aws_instance.flask_server.public_ip}:8080"
}
