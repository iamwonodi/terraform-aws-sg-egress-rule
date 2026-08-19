
# Terraform AWS Security Group Egress Rule


Reusable Terraform module for creating an egress rule on an existing AWS Security Group.


This module is intentionally focused on a single responsibility: managing one security group egress rule.


The security group itself is created separately by the `terraform-aws-security-group` module.


## Architecture


```text
terraform-aws-security-group
            |
            v
      Security Group
            |
            v
terraform-aws-sg-egress-rule
            |
            v
       Egress Rule

Ingress rules are managed independently through the corresponding security-group ingress-rule module.

This separation keeps security-group creation and traffic-policy management independent and reusable.

Features

Creates an egress rule on an existing security group

Supports IPv4 CIDR destinations

Supports security-group destinations

Supports TCP, UDP, ICMP, ICMPv6, and all-protocol rules

Supports configurable source and destination ports where applicable

Provides a description for each rule

Does not depend on subnet tiers or application types

Can be reused across environments and projects

Usage
CIDR-based egress rule
module "https_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v1.0.0"


  security_group_id = module.application_sg.sg_id


  description = "Allow HTTPS outbound traffic"


  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443


  cidr_ipv4 = "0.0.0.0/0"
}
Security-group-to-security-group egress
module "application_to_database" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v1.0.0"


  security_group_id = module.application_sg.sg_id


  description = "Allow application workloads to access the database"


  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432


  referenced_security_group_id = module.database_sg.sg_id
}
All-protocol egress

For an all-protocol rule, use -1:

module "all_outbound" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v1.0.0"


  security_group_id = module.application_sg.sg_id


  description = "Allow all outbound traffic"


  ip_protocol = "-1"


  cidr_ipv4 = "0.0.0.0/0"
}

When ip_protocol is -1, port values are not required.

Design Principles

This module deliberately does not contain knowledge of:

public subnets

private subnets

internal subnets

isolated subnets

frontend applications

APIs

backend services

databases

NAT gateways

load balancers

Those are infrastructure-level concerns.

The module only establishes:

Security Group
      |
      +---- Egress Rule ----> Destination

This allows the same module to be used for different workloads and architectures.

Inputs

Name

	

Description

	

Type

	

Default

	

Required




security_group_id

	

ID of the security group receiving the rule

	

string

	

n/a

	

yes




description

	

Description of the egress rule

	

string

	

n/a

	

yes




ip_protocol

	

Protocol for the rule

	

string

	

-1

	

no




from_port

	

Starting port

	

number

	

null

	

no




to_port

	

Ending port

	

number

	

null

	

no




cidr_ipv4

	

IPv4 CIDR destination

	

string

	

0.0.0.0/0

	

no




referenced_security_group_id

	

Destination security group ID

	

string

	

null

	

no

Outputs

Name

	

Description




egress_rule_id

	

ID of the created security group egress rule

Requirements

Terraform >= 1.5.0

AWS provider >= 6.0.0,