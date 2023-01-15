output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-ami-image.id
}

output "ec2-public_ip" {
  value = aws_instance.myapp-server.public_ip
}