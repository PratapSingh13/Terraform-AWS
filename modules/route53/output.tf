output "zone_ids" {
  value = {
    for k, v in aws_route53_zone.this :
    k => v.zone_id
  }
}

output "record_fqdns" {
  value = {
    for k, v in aws_route53_record.this :
    k => v.fqdn
  }
}
