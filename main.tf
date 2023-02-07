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
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "grafana-subnet" {
  cidr_block = "${cidrsubnet(aws_vpc.grafana-vpc.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.grafana-vpc.id}"
  availability_zone = "eu-central-1a"
}

resource "aws_security_group" "grafana-security-group" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.grafana-vpc.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-06c39ed6b42908a36"
  instance_type = "t2.micro"
  key_name = "aws-terraform"
  security_groups = ["${aws_security_group.grafana-security-group.id}"]
  subnet_id = "${aws_subnet.grafana-subnet.id}"
  tags = {
    Name = "grafana"
  }
}
