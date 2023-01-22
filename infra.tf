

# terraform {
#   backend "s3" {
#     bucket = "aws-infra-terraform-1242123344543"
#     key    = "path/terraform-state"
#     region = "ap-south-1"
#   }
# }

resource "aws_vpc" "webapp-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Webapp-VPC"
  }
}


resource "aws_subnet" "webapp-subnet-1a" {
  vpc_id     = aws_vpc.webapp-vpc.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Webapp-Subnet-1a"
  }
}


resource "aws_subnet" "webapp-subnet-1b" {
  vpc_id     = aws_vpc.webapp-vpc.id 
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Webapp-Subnet-1b"
  }
}



resource "aws_subnet" "webapp-subnet-1c" {
  vpc_id     = aws_vpc.webapp-vpc.id 
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1c"
  
  tags = {
    Name = "Webapp-Subnet-1c"
  }
}



resource "aws_instance" "web-01" {
  ami           = "ami-06984ea821ac0a879"
  instance_type = "t2.micro"
  key_name = "linux-os-key"
  vpc_security_group_ids = [aws_security_group.allow_http.id,aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.webapp-subnet-1a.id

  tags = {
    Name = "Terraform-machine-01"
  }
}



resource "aws_instance" "web-02" {
  ami           = "ami-06984ea821ac0a879"
  instance_type = "t2.micro"
  key_name = "linux-os-key"
  vpc_security_group_ids = [aws_security_group.allow_http.id,aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.webapp-subnet-1b.id

  tags = {
    Name = "Terraform-machine-02"
  }
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

  ingress {
    description      = "http from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "allow_http"
  }
}



resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

  ingress {
    description      = "ssh from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "allow_ssh"
  }
}


resource "aws_internet_gateway" "webapp-IG" {
  vpc_id = aws_vpc.webapp-vpc.id

  tags = {
    Name = "WEBAPP-IG"
  }
}


resource "aws_route_table" "webapp-RT" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-IG.id
  }

  tags = {
    Name = "webapp-RT"
  }
}


resource "aws_route_table_association" "webapp-RT-association-1" {
  subnet_id      = aws_subnet.webapp-subnet-1a.id
  route_table_id = aws_route_table.webapp-RT.id
}


resource "aws_route_table_association" "webapp-RT-association-2" {
  subnet_id      = aws_subnet.webapp-subnet-1b.id
  route_table_id = aws_route_table.webapp-RT.id
}

