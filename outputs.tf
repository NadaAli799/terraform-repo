output "backend_instance_public_ip" {
  description = "The public IP of the backend EC2 instance"
  value       = aws_instance.backend.public_ip
}

output "frontend_instance_public_ip" {
  description = "The public IP of the frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}

output "rds_endpoint" {
  description = "The RDS MySQL endpoint"
  value       = aws_db_instance.mysql_rds.endpoint
}
