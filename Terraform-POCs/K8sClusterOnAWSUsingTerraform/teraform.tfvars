region      = "us-east-1"
agent_count = "2"
# Ubuntu 18.04 image
ami                    = "ami-0e9107ed11be76fde"
instance_type          = "t2.micro"
iam_instance_profile   = "s3ReadOnly"
key_name               = "abba-tf"
# comment out next line if you want to use group name otherwise use id
# security_groups   = ["default", "ssh"]
vpc_security_group_ids = ["sg-0725d0aded136b862"]
