variable "ami_value" {
    description = "value for ami"
    //default = ""  
}

variable "instance_type_value" {
    description = "value for instance_type"
  
}

variable "subnetID_value" {
    description = "value for subnet id"
  
}



provider "aws" {

    region = "us-east-1"
}

resource "aws_instance" "app_server" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    subnet_id = var.subnetID_value
    associate_public_ip_address = true
    key_name = "abba-tf"
    vpc_security_group_ids = [ "sg-0725d0aded136b862" ]
  
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

