provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "skillpulse_ec2" {
  ami           = "ami-0c55b159cbfafe1f0" # Example Ubuntu AMI
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]

  tags = {
    Name = "SkillPulse-Server"
  }
}

resource "aws_security_group" "allow_web_ssh" {
  name        = "allow_web_ssh"
  description = "Allow SSH and HTTP inbound traffic"

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
}
