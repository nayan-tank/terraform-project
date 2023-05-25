variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_a_cidr_block" {
  description = "CIDR block for Subnet A"
  default     = "10.0.1.0/24"
}

variable "subnet_b_cidr_block" {
  description = "CIDR block for Subnet B"
  default     = "10.0.2.0/24"
}

variable "subnet_a_az" {
  description = "Availability Zone for Subnet A"
  default     = "us-east-1a"
}

variable "subnet_b_az" {
  description = "Availability Zone for Subnet B"
  default     = "us-east-1b"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI ID
}

variable "instance_key" {
  description = "EC2 instance key"
  default     = "key-name" # Mention your key-name here
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
