# -----------------------------------------------------------------------------
# Provider
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Example Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "example" {
  name        = "example-egress-rule"
  description = "Security group used by the egress-rule module example."
  vpc_id      = var.vpc_id

  tags = {
    Name = "example-egress-rule"
  }
}

# -----------------------------------------------------------------------------
# IPv4 CIDR Egress
# -----------------------------------------------------------------------------

module "ipv4_egress" {
  source = "../../"

  region = null

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS to the example IPv4 network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"

  tags = {
    Name = "ipv4-https"
  }
}

# -----------------------------------------------------------------------------
# IPv6 CIDR Egress
# -----------------------------------------------------------------------------

module "ipv6_egress" {
  source = "../../"

  region = null

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS to the example IPv6 network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv6 = "2001:db8::/32"

  tags = {
    Name = "ipv6-https"
  }
}

# -----------------------------------------------------------------------------
# Prefix List Egress
# -----------------------------------------------------------------------------

module "prefix_list_egress" {
  source = "../../"

  region = null

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS to the configured prefix list."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  prefix_list_id = var.prefix_list_id

  tags = {
    Name = "prefix-list-https"
  }
}

# -----------------------------------------------------------------------------
# Security Group Egress
# -----------------------------------------------------------------------------

module "security_group_egress" {
  source = "../../"

  region = null

  security_group_id = aws_security_group.example.id
  description       = "Allow PostgreSQL to the configured destination security group."

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  referenced_security_group_id = var.destination_security_group_id

  tags = {
    Name = "security-group-postgresql"
  }
}

# -----------------------------------------------------------------------------
# All-Protocol Egress
# -----------------------------------------------------------------------------

module "all_protocol_egress" {
  source = "../../"

  region = null

  security_group_id = aws_security_group.example.id
  description       = "Allow all protocols to the example IPv4 network."

  ip_protocol = "-1"

  cidr_ipv4 = "10.0.0.0/8"

  tags = {
    Name = "all-protocol"
  }
}
