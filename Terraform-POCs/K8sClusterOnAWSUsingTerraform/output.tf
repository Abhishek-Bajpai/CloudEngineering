output "Master-Node" {
  value = [
    aws_instance.Master-Node.id, 
    aws_instance.Master-Node.private_ip, 
    aws_instance.Master-Node.public_ip, 
  ]
}

output "Agent-Nodes" {
  value = {
    for instance in aws_instance.Agent-Node :
    instance.id => [instance.private_ip, instance.public_ip]
  }
}
