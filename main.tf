provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}


################VPC#########################

resource "aws_vpc" "vpc_main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "vpc main"
  }
}

###################IGW######################

resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "igw main"
  }
}

##################SUBNETS########################


resource "aws_subnet" "subnet_public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.public_subnet_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet public ${count.index} in AZ ${var.public_subnet_azs[count.index]}"
  }
}




#####################ROUTE TABLES#########################

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }


  tags = {
    Name = "route-table-public"
  }
}


#####################ROUTE TABLES ASSOCIATIONS#########################

resource "aws_route_table_association" "pub" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.rt_public.id
}


#####################Ec2 instances#########################


resource "aws_instance" "ec2_main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_public.id]
  key_name = var.ec2_key_name
  subnet_id = aws_subnet.subnet_public[0].id
  tags = {
    Name = "aws-ec2-public-name"
  }
}


#####################SG#########################

resource "aws_security_group" "sg_public" {
  name        = "sg_main_ngninx"
  description = "Allow ssh from everywhere to public servers"
  vpc_id      = aws_vpc.vpc_main.id


   ingress {
    description = "ssh from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_public"
  }
}