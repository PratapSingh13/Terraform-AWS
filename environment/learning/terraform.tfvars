# ################################################################################
# Global
# ################################################################################
region      = "ap-south-1"
project     = "aws-terraform"
managed_by  = "Terraform"
owner       = "DevOps"
environment = "learning"

# ################################################################################
# VPC
# ################################################################################
vpc_cidr = "10.0.0.0/16"

# ################################################################################
# Public and Private Subnets
# ################################################################################

public_subnets_cidr  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]

# ################################################################################
# Security Group
# ################################################################################
create_security_group          = true
security_group_use_name_prefix = false
security_group_ingress_rules = {
  http = {
    ip_protocol = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_ipv4   = "0.0.0.0/0"
  }
  https = {
    ip_protocol = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_ipv4   = "0.0.0.0/0"
  }
}

security_group_egress_rules = {
  all_outbound = {
    ip_protocol = "-1"
    from_port   = 0
    to_port     = 0
    cidr_ipv4   = "0.0.0.0/0"
  }
}

# ################################################################################
# VPC Peering
# ################################################################################
enable_vpc_peering = true

vpc_peerings = {
  "peering-1" = {
    peer_owner_id                             = "590379872770"
    peer_vpc_id                               = "vpc-09743f2c8b1ab0128"
    peer_region                               = "ap-south-1"
    destination_vpc_cidr                      = "172.31.0.0/16"
    allow_remote_vpc_dns_resolution_accepter  = false
    allow_remote_vpc_dns_resolution_requester = false
  }

  "peering-2" = {
    peer_owner_id                             = "590379872770"
    peer_vpc_id                               = "vpc-00c60f96b30ca8c0b"
    peer_region                               = "ap-south-1"
    destination_vpc_cidr                      = "192.168.0.0/16"
    allow_remote_vpc_dns_resolution_accepter  = false
    allow_remote_vpc_dns_resolution_requester = false
  }
}

# ################################################################################
# IAM Users
# ################################################################################
users = {
  "alice" = {
    console_access  = true
    pgp_key         = null # or base64 PGP key
    password_length = 20
    password        = "YourSecretPassword123!"
  }
  "bob" = {
    console_access = false
    pgp_key        = null
  }
}

# ################################################################################
# IAM Policies
# ################################################################################
policies = {

  s3_read_only = {
    description = "S3 read only access"
    policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = "*"
        }
      ]
    }
  }

  ec2_read_only = {
    description = "EC2 describe access"
    policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["ec2:Describe*"]
          Resource = "*"
        }
      ]
    }
  }

  cross_service_policy = {
    description = "Multi-service access"
    policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "ec2:DescribeInstances",
            "logs:CreateLogGroup"
          ]
          Resource = "*"
        }
      ]
    }
  }
}