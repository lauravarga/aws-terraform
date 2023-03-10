provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_vpc" "grafana-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "grafana-vpc"
  }
}

resource "aws_subnet" "grafana-subnet-public" {
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.grafana-vpc.id
  availability_zone = "eu-central-1a"
  tags = {
    Name = "grafana-subnet-public"
  }
}

resource "aws_subnet" "grafana-subnet-private" {
  cidr_block        = "10.0.99.0/24"
  vpc_id            = aws_vpc.grafana-vpc.id
  availability_zone = "eu-central-1a"
  tags = {
    Name = "grafana-subnet-private"
  }
}

resource "aws_route_table" "grafana-route-table" {
  vpc_id = aws_vpc.grafana-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grafana-igw.id
  }
  tags = {
    Name = "grafana-route-table"
  }
}
resource "aws_route_table_association" "grafana-subnet-association-public" {
  subnet_id      = aws_subnet.grafana-subnet-public.id
  route_table_id = aws_vpc.grafana-vpc.main_route_table_id
}
resource "aws_route_table_association" "grafana-subnet-association-private" {
  subnet_id      = aws_subnet.grafana-subnet-private.id
  route_table_id = aws_route_table.grafana-route-table.id
}

resource "aws_security_group" "grafana-security-group" {
  name   = "grafana-security-group"
  vpc_id = aws_vpc.grafana-vpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    description = "allow ssh port"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 0
    to_port     = 3000
    protocol    = "tcp"
    description = "allow grafana port"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "grafana-igw" {
  vpc_id = aws_vpc.grafana-vpc.id
  tags = {
    Name = "grafana-igw"
  }

}

resource "aws_route" "route-public" {
  route_table_id         = aws_vpc.grafana-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.grafana-igw.id
}


