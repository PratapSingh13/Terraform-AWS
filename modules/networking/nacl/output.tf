output "nacl_ids" {
  description = "Map of NACL IDs"
  value = {
    for k, v in aws_network_acl.this : k => v.id
  }
}
