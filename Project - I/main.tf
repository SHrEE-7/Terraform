provider "aws" {}

variable "vpc_cider_block" {}
variable "subnet_cider_block" {}
variable "avail_zone" {}
variable "env_prefix" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cider_block
  tags = {
    "Name" = "${env.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cider_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "Value"
  }
}