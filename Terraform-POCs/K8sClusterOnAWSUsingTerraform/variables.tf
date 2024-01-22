variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
  default     = ""
}

variable "region" {
  description = "region to be used on all resources"
  type        = string
  default = "us-east-1"
}

variable "agent_count" {
  description = "Number of instances to launch"
  type        = number
  default     = "2"
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = "ami-0e9107ed11be76fde"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default = "t2.micro"
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
  default     = "abba-tf"
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of VPC Subnet IDs to launch in"
  type        = list(string)
  default     = []
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

