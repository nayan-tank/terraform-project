resource "aws_efs_file_system" "main" {
  creation_token = "${var.basename}-efs"
  performance_mode = var.efs_performance_mode
  throughput_mode = var.efs_throughput_mode
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_${var.transition_to_ia_days}_DAYS"
  }

  tags = {
    Name = "${var.basename}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_mount_targets.id]


}

resource "aws_security_group" "efs_mount_targets" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.basename}-efs-mount-target-sg"
  }
}