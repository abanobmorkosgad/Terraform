provider "aws" {
    region = "us-east-1"
}

variable "subnet_cidr" {
    description = "subnet cidr"
}

variable "TerraformVPC_cidr" {
   description = "TerraformVPC cidr"
}

resource "aws_vpc" "TerraformVPC" {
    cidr_block = var.TerraformVPC_cidr
    tags = {
    Name = "main"
    }
}

resource "aws_subnet" "TerraformSubnet1" {
    vpc_id     = aws_vpc.TerraformVPC.id
    cidr_block = var.subnet_cidr
    availability_zone= "us-east-1a"
    tags = {
    Name = "subnet1_main"
    }
}

data "aws_vpc" "existing" {
    default = true
}

resource "aws_subnet" "TerraformSubnet2" {
    vpc_id = data.aws_vpc.existing.id
    cidr_block = "172.31.96.0/20"
    availability_zone= "us-east-1a"
    tags = {
    Name = "subnet2"
    }
}