output "egress_rule_id" {
  description = "The ID of the security group egress rule."
  value       = aws_vpc_security_group_egress_rule.this.id
}