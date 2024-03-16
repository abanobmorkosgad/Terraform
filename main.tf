provider "aws" {
    region = "us-east-1"
}

variable subnet_cidr {}
variable vpc_cidr {}
variable avail_zone {}
variable env {}
variable instance_type {}
variable my_ip {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.env}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet1" {
    vpc_id     = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr
    availability_zone= var.avail_zone
    tags = {
        Name = "${var.env}-subnet-1"
    }
}

resource "aws_route_table" "myapp-routetable" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-gw.id
  }

  tags = {
    Name = "${var.env}-routetable"
  }
}

resource "aws_internet_gateway" "myapp-gw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env}-gw"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.myapp-subnet1.id
  route_table_id = aws_route_table.myapp-routetable.id
}

resource "aws_security_group" "my-app-sg" {
    name = "my-app sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
    Name = "${var.env}-sg"
    }
}

data "aws_ami" "amazon_linux_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.3.20240312.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] 
}
output "aws_ami_id" {
    value = data.aws_ami.amazon_linux_image.id
}
output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.amazon_linux_image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet1.id
  security_groups = [aws_security_group.my-app-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "Test"

  user_data = file("entryscript.sh")

  tags = {
    Name = "${var.env}-server"
  }
}