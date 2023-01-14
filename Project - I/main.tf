provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cider_block" {}
variable "subnet_cider_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cider_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cider_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    "Name" = "${var.env_prefix}-igw"
  }
}

// Resource which cretes new route table.
# resource "aws_route_table" "myapp-rtb" {
#   vpc_id = aws_vpc.myapp-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     "Name" = "${var.env_prefix}-rtb"
#   }
# }

//Use Default reoute table & manage igw.
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    "Name" = "${var.env_prefix}-main-rtb"
  }
}

//Secuirity Group
resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = [var.my_ip]
  }
}