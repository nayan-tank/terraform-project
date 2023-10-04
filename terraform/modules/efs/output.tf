output "efs_id" {
  description = "ID of EFS"
  value       = aws_efs_file_system.main.id
}