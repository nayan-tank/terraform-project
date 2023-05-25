 # Configure AWS provider
 provider "aws" {
   region = var.aws_region
 }

 # Create VPC
 resource "aws_vpc" "my_vpc" {
   cidr_block = var.vpc_cidr_block
 }

 # Create two subnets in separate AZs
 resource "aws_subnet" "subnet_a" {
   vpc_id                  = aws_vpc.my_vpc.id
   cidr_block              = var.subnet_a_cidr_block
   availability_zone       = var.subnet_a_az
 }

 resource "aws_subnet" "subnet_b" {
   vpc_id                  = aws_vpc.my_vpc.id
   cidr_block              = var.subnet_b_cidr_block
   availability_zone       = var.subnet_b_az
 }

 # Create security group
 resource "aws_security_group" "my_security_group" {
   name        = "my-security-group"
   vpc_id      = "${aws_vpc.my_vpc.id}"
   description = "Allow SSH inbound traffic"

   ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

     ingress {
     from_port   = 0 #(any port)
     to_port     = 0 #(any port)
     protocol    = "-1" #(all protocol)
     cidr_blocks = ["0.0.0.0/0"]
   }
 }

 # Launch EC2 instances
 resource "aws_instance" "instance_a" {
   ami           = var.ami_id
   instance_type = var.instance_type
   subnet_id     = aws_subnet.subnet_a.id
   key_name      = var.instance_key
   vpc_security_group_ids = [aws_security_group.my_security_group.id]

   tags = {
     Name = "Instance A"
   }
 }

 resource "aws_instance" "instance_b" {
   ami           = var.ami_id
   instance_type = var.instance_type
   subnet_id     = aws_subnet.subnet_b.id
   key_name      = var.instance_key
   vpc_security_group_ids = [aws_security_group.my_security_group.id]

   tags = {
     Name = "Instance B"
   }
 }
