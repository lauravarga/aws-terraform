provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "grafana-ec2" {
  ami             = "ami-06c39ed6b42908a36"
  instance_type   = "t2.micro"
  key_name        = "aws-terraform"
  security_groups = ["sg-009f63dbcb79bf7fd"]
  subnet_id       = "subnet-0763649b34226ba35"
  tags = {
    Name = "grafana"
  }
}

resource "aws_eip" "grafana-public-ip" {
  instance   = aws_instance.grafana-ec2.id
  vpc        = true
  tags = {
    Name = "grafana-public-ip"
  }
}
