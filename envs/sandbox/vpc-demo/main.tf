terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "mycompany-tfstate-sandbox-123456789012" # your existing tfstate bucket
    key          = "vpc-demo/terraform.tfstate"             # separate state file for this project
    region       = "eu-west-1"
    profile      = "sandbox"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "sandbox"
}

# ------------------------------
# VPC
# ------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sandbox-vpc"
    env  = "sandbox"
  }
}

# ------------------------------
# Internet Gateway (for public subnets)
# ------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sandbox-igw"
    env  = "sandbox"
  }
}

# ------------------------------
# Subnets
# We'll create 2 public + 2 private subnets across 2 AZs
# ------------------------------

# Public subnet in eu-west-1a
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sandbox-public-a"
    env  = "sandbox"
  }
}

# Public subnet in eu-west-1b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "sandbox-public-b"
    env  = "sandbox"
  }
}

# Private subnet in eu-west-1a
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "sandbox-private-a"
    env  = "sandbox"
  }
}

# Private subnet in eu-west-1b
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "sandbox-private-b"
    env  = "sandbox"
  }
}

# ------------------------------
# Route table for public subnets
# ------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "sandbox-public-rt"
    env  = "sandbox"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------
# Outputs (so you can see IDs easily)
# ------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]
}
