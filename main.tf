terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "eu-central-1"
}


resource "aws_vpc" "basicvpc-dd" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "basicvpc-dd"
  }
}


resource "aws_subnet" "basicsubnet-dd" {
  vpc_id     = aws_vpc.basicvpc-dd.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "basicsubnet-dd"
  }
}

resource "aws_internet_gateway" "basicgw-dd" {
  vpc_id = aws_vpc.basicvpc-dd.id

  tags = {
    Name = "main"
  }
}


resource "aws_route_table_association" "basicsubnetassoc-dd" {
  subnet_id      = aws_subnet.basicsubnet-dd.id
  route_table_id = aws_route_table.basicrt-dd.id
}

resource "aws_route_table" "basicrt-dd" {
  vpc_id = aws_vpc.basicvpc-dd.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.basicgw-dd.id
  }
 
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.basicsubnet-dd.id
  route_table_id = aws_route_table.basicrt-dd.id
}


resource "aws_security_group" "basicsecgroup-dd" {
  description = "basicsecgroup-dd"
  vpc_id      = aws_vpc.basicvpc-dd.id

#   ingress {
#     description = "SSH"
#     from_port   = 22 # SSH client port is not a fixed port
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  ingress {
  description = "SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



resource "aws_instance" "ec2-tf" {
  ami           = "ami-0ec7f9846da6b0f61"
  instance_type = "t3.micro"
  subnet_id                   = aws_subnet.basicsubnet-dd.id
  vpc_security_group_ids= [aws_security_group.basicsecgroup-dd.id]

  key_name                    = "domotor_david_1.2"

  associate_public_ip_address = true
  tags = {
    Name = "basic subnet tag"
  }
}

output "public_ip" {
  value = aws_instance.ec2-tf.public_ip
}



