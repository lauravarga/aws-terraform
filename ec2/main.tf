provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "grafana-ec2" {
  ami             = "ami-06c39ed6b42908a36"
  instance_type   = "t2.micro"
  key_name        = "aws-terraform"
  security_groups = ["${aws_security_group.grafana-security-group.id}"]
  subnet_id       = aws_subnet.grafana-subnet-public.id
  tags = {
    Name = "grafana"
  }
}
