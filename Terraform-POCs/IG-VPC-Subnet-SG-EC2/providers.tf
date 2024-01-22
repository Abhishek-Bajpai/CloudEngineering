terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "access_key" {
    description = "AWS Access Key value"
}

variable "secret_key" {
    description = "AWS Secret Key value"
  
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a VPC
resource "aws_vpc" "tf-created-vpc" {
  cidr_block = "172.0.0.0/16"
  //assign_generated_ipv6_cidr_block = true
    tags = {
        Name = "tf-automated"
  }
}

//create subnet
resource "aws_subnet" "tf-created-subnet" {
  vpc_id     = aws_vpc.tf-created-vpc.id
  cidr_block = "172.0.1.0/24"

  tags = {
    Name = "tf-automated"
  }
}

resource "aws_internet_gateway" "tf-created-igw" {
  vpc_id = aws_vpc.tf-created-vpc.id

  tags = {
    Name = "tf-automated"
  }
}

resource "aws_route_table" "tf-created-route_table" {
  vpc_id = aws_vpc.tf-created-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-created-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.tf-created-egress_only_internet_gateway.id
  }

  tags = {
    Name = "tf-automated"
  }
}


resource "aws_egress_only_internet_gateway" "tf-created-egress_only_internet_gateway" {
  vpc_id = aws_vpc.tf-created-vpc.id

  tags = {
    Name = "tf-automated"
  }
}

///Create Security Group
resource "aws_security_group" "tf-created-SecGrp-allow_tls" {

  vpc_id      = aws_vpc.tf-created-vpc.id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "tf-automated=SG"
  }
}


//Create an EC2 with this config
variable "ami_id" {
  
}

variable "instance_type" {
  
}

resource "aws_instance" "tf-webserver-ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.tf-created-SecGrp-allow_tls.id ]
  subnet_id     = aws_subnet.tf-created-subnet.id
  associate_public_ip_address = true
  key_name = "abba-tf"
  tags = {
    Name = "web_server-ec2"
  }
}