output "vpc_peering_id" {
  description = "The ID of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.peering.id
}
