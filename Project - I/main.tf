provider "aws" {
  region = "ap-south-1"
}

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

// Resource which creates new route table.
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
# resource "aws_security_group" "myapp-sg" {
#   name = "myapp-sg"
#   vpc_id = aws_vpc.myapp-vpc.id

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.my_ip]
#   }

#   ingress {
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   cidr_blocks = [var.my_ip]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     prefix_list_ids = []
#   }

#   tags = {
#     "Name" = "${var.env_prefix}-sg"
#   }
# }

//Default Security Group for myapp-VPC
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]       //[var.my_ip]
  }

  ingress {
  from_port = 80
  to_port = 80
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
    "Name" = "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-ami-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  # filter {
  #   name = "Virtualization"
  #   values = ["hvm"]
  # }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "Server-key"
  public_key = file(var.public_key_location)
}


resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-ami-image.id
  instance_type = var.instance_type
  
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
  
}