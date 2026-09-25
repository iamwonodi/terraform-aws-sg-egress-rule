# -----------------------------------------------------------------------------
# Security Group Egress Rule ID
# -----------------------------------------------------------------------------

output "id" {
  description = "The ID of the security group egress rule."
  value       = aws_vpc_security_group_egress_rule.this.id
}

# -----------------------------------------------------------------------------
# Security Group Egress Rule ARN
# -----------------------------------------------------------------------------

output "arn" {
  description = "The ARN of the security group egress rule."
  value       = aws_vpc_security_group_egress_rule.this.arn
}

# -----------------------------------------------------------------------------
# Target Security Group ID
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the security group receiving the egress rule."
  value       = aws_vpc_security_group_egress_rule.this.security_group_id
}