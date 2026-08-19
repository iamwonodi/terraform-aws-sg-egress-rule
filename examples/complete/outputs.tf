output "egress_rule_id" {
  description = "ID of the created security group egress rule."
  value       = module.sg_egress_rule.egress_rule_id
}