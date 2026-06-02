output "subnet_cidr" {
  value = aws_subnet.subnet[*].cidr_block
}

output "subnet_ids" {
  value = aws_subnet.subnet[*].id
}
