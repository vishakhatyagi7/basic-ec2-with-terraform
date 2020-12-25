output "public_ec2_ip4_address" {
    value = aws_instance.ec2_main.public_ip
}