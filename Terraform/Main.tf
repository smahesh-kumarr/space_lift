provider "aws" {
  region = "us-east-1"
}

# VPC for Spacelift
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Spacelift-VPC"
  }
}

# Public Subnet for Spacelift VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-spacelift"
  }
}

# Private Subnet for Spacelift VPC
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "private-subnet-spacelift"
  }
}

# Internet Gateway for Spacelift VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW-Spacelift"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public-Route-Table-Spacelift"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public-rtb-assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rtb.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "nat-gateway"
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "Private-Route-Table-Spacelift"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private-rtb-assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-rtb.id
}

# Security Group for EC2 Instances
resource "aws_security_group" "public-sg" {
  name        = "ec2-sg-spacelift"
  description = "Public Security Group for Spacelift"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
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
    Name = "ec2-sg-spacelift"
  }
}

# Reference Existing Key Pair
resource "aws_key_pair" "mahesh_key" {
  key_name   = "Mahesh"
  public_key = file("~/.ssh/Mahesh.pub") # Path to your public key
}

# EC2 Instances in Public Subnet
resource "aws_instance" "public" {
  count                  = 2
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  key_name               = aws_key_pair.mahesh_key.key_name
  tags = {
    Name = "public-ec2-${count.index + 1}"
  }
}

# EC2 Instances in Private Subnet
resource "aws_instance" "private" {
  count                  = 2
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  key_name               = aws_key_pair.mahesh_key.key_name
  tags = {
    Name = "private-ec2-${count.index + 1}"
  }
}

# Output Public IPs of Public Subnet Instances
output "public_instance_ips" {
  value = aws_instance.public[*].public_ip
}

# Output Private IPs of Private Subnet Instances
output "private_instance_ips" {
  value = aws_instance.private[*].private_ip
}