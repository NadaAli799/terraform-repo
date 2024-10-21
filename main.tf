provider "aws" {
  region = "us-east-1"  
}

# Create VPC or use default
resource "aws_vpc" "default" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecommerce-default-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "default_igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "ecommerce-igw"
  }
}

# Subnet for frontend/backend machines
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" 

  tags = {
    Name = "ecommerce-public-subnet"
  }
}

# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "ecommerce-ec2-sg"
  }
}

# Backend EC2 Instance
resource "aws_instance" "backend" {
  ami                         = "ami-0a313d6098716f372"  # Ubuntu 22.04 AMI ID
  instance_type               = "t2.micro"  # 1 core, 1 GB RAM
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ecommerce-backend"
  }

  root_block_device {
    volume_size = 8
  }
}

# Frontend EC2 Instance
resource "aws_instance" "frontend" {
  ami                         = "ami-0a313d6098716f372"  
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "ecommerce-frontend"
  }

  root_block_device {
    volume_size = 8
  }
}

# Security group for MySQL RDS (allow only EC2 instances access)
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]  # Only accessible from the frontend/backend subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-rds-sg"
  }
}

# MySQL RDS Instance (No public access)
resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false

  tags = {
    Name = "ecommerce-mysql-rds"
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "ecommerce-rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id]

  tags = {
    Name = "ecommerce-rds-subnet-group"
  }
}
