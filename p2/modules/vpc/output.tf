output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "private_subnet_id" {
  value = {
    for key, subnet in aws_subnet.private_subnet:
    key => subnet.id
  }
}
output "public_subnet_id" {
  value = {
    for key, subnet in aws_subnet.public_subnet:
    key => subnet.id
  }
}
