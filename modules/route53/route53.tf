############################################
# Hosted Zones
############################################
resource "aws_route53_zone" "this" {
  for_each = var.zones

  name = each.value.name

  dynamic "vpc" {
    for_each = each.value.vpc_ids
    content {
      vpc_id = vpc.value
    }
  }

  tags = var.tags
}

############################################
# Health Checks
############################################
resource "aws_route53_health_check" "this" {
  for_each = var.health_checks

  fqdn          = each.value.fqdn
  type          = each.value.type
  resource_path = lookup(each.value, "resource_path", null)

  failure_threshold = 3
  request_interval  = 30

  tags = var.tags
}

############################################
# Records
############################################
resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = aws_route53_zone.this[each.value.zone_key].zone_id
  name    = each.value.name
  type    = each.value.type

  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  ##########################################
  # Alias
  ##########################################
  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = false
    }
  }

  set_identifier = lookup(each.value, "set_identifier", null)

  ##########################################
  # Routing Policies
  ##########################################
  dynamic "weighted_routing_policy" {
    for_each = lookup(each.value, "weight", null) != null ? [1] : []
    content {
      weight = each.value.weight
    }
  }

  dynamic "failover_routing_policy" {
    for_each = lookup(each.value, "failover", null) != null ? [1] : []
    content {
      type = each.value.failover
    }
  }

  dynamic "latency_routing_policy" {
    for_each = lookup(each.value, "region", null) != null ? [1] : []
    content {
      region = each.value.region
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = lookup(each.value, "geo", null) != null ? [each.value.geo] : []
    content {
      continent = lookup(geolocation_routing_policy.value, "continent", null)
      country   = lookup(geolocation_routing_policy.value, "country", null)
    }
  }

  dynamic "geoproximity_routing_policy" {
    for_each = lookup(each.value, "geoproximity", null) != null ? [each.value.geoproximity] : []
    content {
      aws_region = lookup(geoproximity_routing_policy.value, "aws_region", null)
      bias       = lookup(geoproximity_routing_policy.value, "bias", null)

      dynamic "coordinates" {
        for_each = lookup(geoproximity_routing_policy.value, "coordinates", null) != null ? [geoproximity_routing_policy.value.coordinates] : []
        content {
          latitude  = coordinates.value.latitude
          longitude = coordinates.value.longitude
        }
      }
    }
  }

  ##########################################
  # Health Check Mapping
  ##########################################
  health_check_id = lookup(each.value, "health_check_id", null) != null ? aws_route53_health_check.this[each.value.health_check_id].id : null
}