# -----------------------------------------------------------------------------
# IPv4 Egress Rule
# -----------------------------------------------------------------------------

output "ipv4_egress_rule_id" {
  description = "ID of the IPv4 CIDR egress rule."
  value       = module.ipv4_egress.id
}

# -----------------------------------------------------------------------------
# IPv6 Egress Rule
# -----------------------------------------------------------------------------

output "ipv6_egress_rule_id" {
  description = "ID of the IPv6 CIDR egress rule."
  value       = module.ipv6_egress.id
}

# -----------------------------------------------------------------------------
# Prefix List Egress Rule
# -----------------------------------------------------------------------------

output "prefix_list_egress_rule_id" {
  description = "ID of the prefix-list egress rule."
  value       = module.prefix_list_egress.id
}

# -----------------------------------------------------------------------------
# Security Group Egress Rule
# -----------------------------------------------------------------------------

output "security_group_egress_rule_id" {
  description = "ID of the security-group-based egress rule."
  value       = module.security_group_egress.id
}

# -----------------------------------------------------------------------------
# All-Protocol Egress Rule
# -----------------------------------------------------------------------------

output "all_protocol_egress_rule_id" {
  description = "ID of the all-protocol egress rule."
  value       = module.all_protocol_egress.id
}