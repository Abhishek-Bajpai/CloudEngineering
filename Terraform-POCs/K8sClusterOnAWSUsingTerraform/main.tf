terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Generate kubeadm init token
resource "random_string" "token-id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token-secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token = "${random_string.token-id.result}.${random_string.token-secret.result}"
}

# Create master node
resource "aws_instance" "Master-Node" {
  ami                    = "ami-0e9107ed11be76fde"//var.ami
  instance_type          = "t2.micro" //var.instance_type
  //iam_instance_profile   = var.iam_instance_profile
  key_name               = "abba-tf"//var.key_name
  vpc_security_group_ids =  ["sg-0725d0aded136b862"]//var.vpc_security_group_ids
  source_dest_check      = "false"
  subnet_id              = "subnet-0f94a33772d92921c"//"subnet-0d8e386b"
  associate_public_ip_address = true
  user_data              = <<-EOF
  #!/bin/bash
  apt update -y
  apt install docker.io -y
  systemctl enable docker.service
  usermod -aG docker ubuntu
  apt install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
  apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  apt update -y
  apt install -y kubelet kubeadm kubectl
  sysctl -w net.ipv4.ip_forward=1
  sed -i 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/Ig' /etc/sysctl.conf
  # Ignore preflight in order to have master running on t2.micro, otherwise remove it 
  kubeadm init --token ${local.token} \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --ignore-preflight-errors=all
  sleep 30
  mkdir -p /home/ubuntu/.kube ~/.kube
  cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
  chown ubuntu:ubuntu /home/ubuntu/.kube/config
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  # while [[ $(kubectl -n kube-system get pods -l k8s-app=kube-dns -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do sleep 5; done
  EOF
  tags = {
    Owner      = "Engineering"
    Stack      = "Dev"
    Kubernetes = "Master"
    Name = "K8sMaster"
  }
}

# Create agents
resource "aws_instance" "Agent-Node" {
  count = var.agent_count

  ami                    = "ami-0e9107ed11be76fde"//var.ami
  instance_type          = "t2.micro"//var.instance_type
  //iam_instance_profile   = var.iam_instance_profile
  key_name               = "abba-tf"//var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  source_dest_check      = "false"
  subnet_id              = "subnet-0f94a33772d92921c"//"subnet-0d8e386b"
  user_data              = <<-EOF
  #!/bin/bash
  apt update -y
  apt install docker.io -y
  systemctl enable docker.service
  usermod -aG docker ubuntu
  apt install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
  apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  apt update -y
  apt install -y kubelet kubeadm kubectl
  sysctl -w net.ipv4.ip_forward=1
  sed -i 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/Ig' /etc/sysctl.conf
  kubeadm join ${aws_instance.Master-Node.private_ip}:6443 \
  --token ${local.token} \
  --discovery-token-unsafe-skip-ca-verification
  EOF
  tags = {
    Owner      = "Engineering"
    Stack      = "Dev"
    Kubernetes = "Node"
    Name = "K8sWorker-${count.index + 1}"
  }
  depends_on = [
    aws_instance.Master-Node
  ]
}
