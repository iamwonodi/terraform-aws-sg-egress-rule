module "sg_egress_rule" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v1.0.0"

  security_group_id = var.security_group_id

  description = "Allow HTTPS outbound traffic"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}


module "backend_to_database" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v1.0.0"

  security_group_id = module.backend_sg.sg_id

  description = "Allow backend services to access PostgreSQL database"

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  referenced_security_group_id = module.database_sg.sg_id
}