# 1. Dynamic AMI Lookup for Ubuntu 22.04
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Improved Security Group Configuration
resource "aws_security_group" "allow_web_ssh" {
  name        = "skillpulse_sg_${var.common_tags["Environment"]}"
  description = "Security group for SkillPulse EC2 instance"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  ingress {
    description = "HTTP access for web/frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidr_blocks
  }

  ingress {
    description = "Custom backend port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "SkillPulse-SG"
  })
}

# 3. EC2 Instance Configuration
resource "aws_instance" "skillpulse_ec2" {
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.allow_web_ssh.id]

  # Prepare root volume for Docker/K8s
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  
  user_data = replace(file("${path.module}/userdata.sh"), "\r", "")
  user_data_replace_on_change = true
  monitoring = true # Detailed monitoring

  tags = merge(var.common_tags, {
    Name = "SkillPulse-Server"
  })
}
