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

resource "aws_eip" "grafana-public-ip" {
  #   instance = aws_instance.grafana-ec2.id
  depends_on = [aws_internet_gateway.grafana-igw]
  vpc        = true
  tags = {
    Name = "grafana-public-ip"
  }
}
resource "aws_subnet" "grafana-subnet-public" {
  cidr_block        = cidrsubnet(aws_vpc.grafana-vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.grafana-vpc.id
  availability_zone = "eu-central-1a"
  tags = {
    Name = "grafana-subnet-public"
  }
}

resource "aws_subnet" "grafana-subnet-private" {
  cidr_block        = cidrsubnet(aws_vpc.grafana-vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.grafana-vpc.id
  availability_zone = "eu-central-1a"
  tags = {
    Name = "grafana-subnet-private"
  }
}

resource "aws_nat_gateway" "grafana-nat-gw" {
  subnet_id     = aws_subnet.grafana-subnet-public
  allocation_id = aws_eip.grafana-public-ip.id

  tags = {
    Name = "grafana-nat-gw"
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
  subnet_id      = aws_subnet.grafana-subnet-public
  route_table_id = aws_vpc.grafana-vpc
}
resource "aws_route_table_association" "grafana-subnet-association-private" {
  subnet_id      = aws_subnet.grafana-subnet-private
  route_table_id = aws_route_table.grafana-route-table
}

resource "aws_security_group" "grafana-security-group" {
  name   = "allow-all-sg"
  vpc_id = aws_vpc.grafana-vpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
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

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "grafana-ec2" {
  ami             = "ami-06c39ed6b42908a36"
  instance_type   = "t2.micro"
  key_name        = "aws-terraform"
  security_groups = ["${aws_security_group.grafana-security-group.id}"]
  subnet_id       = aws_subnet.grafana-subnet-private.id
  tags = {
    Name = "grafana"
  }
}
