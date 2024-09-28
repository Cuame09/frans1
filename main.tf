# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}




resource "aws_vpc" "frans1" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "frans1"
    Env  = "Production"
  }
}

# 2 Public subnets

resource "aws_subnet" "frans1-pub-sub1" {
  vpc_id            = aws_vpc.frans1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "TERRA"
  }
}

resource "aws_subnet" "frans1-pub-sub2" {
  vpc_id                  = aws_vpc.frans1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "frans1"
  }
}

# 2 Private subnets

resource "aws_subnet" "frans1-priv-sub1" {
  vpc_id     = aws_vpc.frans1.id
  cidr_block = "10.0.3.0/24"


  tags = {
    Name = "frans"
  }
}

resource "aws_subnet" "frans1-priv-sub2" {
  vpc_id     = aws_vpc.frans1.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "frans"
  }
}

# CREATING INTERNET GATEWAY

resource "aws_internet_gateway" "frans1-igw" {
  vpc_id = aws_vpc.frans1.id

  tags = {
    Name = "frans1"
  }
}

# CREATING EIPs 

resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.frans1-igw]
}

#CREATING NAT GATEWAY

resource "aws_nat_gateway" "frans1-ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.frans1-pub-sub1.id

  tags = {
    Name = "frans1-ngw"
  }

}

# TWO ROUTE TABLES FOR THE NETWORK

resource "aws_route_table" "frans1-pub-rt" {
  vpc_id = aws_vpc.frans1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.frans1-igw.id
  }

  tags = {
    Name = "frans1-pub-rt"
  }
}

resource "aws_route_table" "frans1-priv-rt" {
  vpc_id = aws_vpc.frans1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.frans1-ngw.id
  }

  tags = {
    Name = "frans1-priv-rt"
  }
}

# ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.frans1-pub-sub1.id
  route_table_id = aws_route_table.frans1-pub-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.frans1-pub-sub2.id
  route_table_id = aws_route_table.frans1-priv-rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.frans1-priv-sub1.id
  route_table_id = aws_route_table.frans1-priv-rt.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.frans1-priv-sub2.id
  route_table_id = aws_route_table.frans1-priv-rt.id
}

resource "aws_security_group" "frans1-vpc" {
  name        = "Project-vpc-sg"
  description = "Project-vpc-sg"
  vpc_id      = aws_vpc.frans1.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "frans1-sg"
  }
}

# creating ec2

resource "aws_instance" "frans1-ec2" {
  ami               = "ami-0a2202cf4c36161a1"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-1b"
  subnet_id         = aws_subnet.frans1-pub-sub2.id
  security_groups   = [aws_security_group.frans1-vpc.id]

  tags = {
    Name = "frans1-ec2"
  }
}

resource "aws_s3_bucket" "frans1-s3" {
  bucket = "mytfprojectbucket"
}