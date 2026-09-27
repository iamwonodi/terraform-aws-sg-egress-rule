# Terraform AWS Security Group Egress Rule

Reusable Terraform module for creating a **single egress rule** on an existing AWS Security Group.

The module is intentionally focused on one responsibility:

```text
Security Group
   |
   v
Egress Rule
   |
   v
Destination
```

The security group itself is created separately. Ingress rules are managed independently through the corresponding security-group ingress-rule module.

---

# Architecture

```text
                ┌──────────────────────────┐
                │   Existing Security      │
                │          Group           │
                └────────────┬─────────────┘
                             │
                             v
                ┌──────────────────────────┐
                │  SG Egress Rule Module   │
                └────────────┬─────────────┘
                             │
              ┌──────────────┼────────────────┐
              │              │                │
              v              v                v
       IPv4 / IPv6      Prefix List     Security Group
           CIDR         Destination        Reference
```

The module does **not** create the security group.

The consuming infrastructure is responsible for deciding:

* Which security group receives the rule
* Which destination is allowed
* Which protocol is allowed
* Which ports or ICMP type/code are allowed
* Why the rule exists
* Which AWS Region manages the rule

---

# Features

* Creates a single egress rule on an existing security group
* Supports IPv4 CIDR destinations
* Supports IPv6 CIDR destinations
* Supports AWS-managed and customer-managed prefix lists
* Supports security-group references
* Supports configurable AWS Region
* Supports resource tags
* Supports TCP, UDP, ICMP, ICMPv6, and all-protocol rules using `-1`
* Supports ICMP type/code through `from_port` and `to_port`
* Validates the traffic destination and the address family of each CIDR input
* Prevents multiple traffic destinations from being configured simultaneously
* Does not default egress traffic to the internet
* Does not contain application-specific infrastructure logic

---

# Destination Types

Exactly **one** traffic destination must be provided for each egress rule:

```text
cidr_ipv4

cidr_ipv6

prefix_list_id

referenced_security_group_id
```

---

## IPv4 CIDR Destination

```hcl
module "https_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS to the internal network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"
}
```

---

## IPv6 CIDR Destination

```hcl
module "https_ipv6_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS to the IPv6 network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv6 = "2001:db8::/32"
}
```

---

## Prefix List Destination

Use `prefix_list_id` when traffic should be allowed to an AWS-managed or customer-managed prefix list.

A common case is S3 through a gateway VPC endpoint: the endpoint's prefix list holds S3's address ranges in the Region, so the rule needs no hard-coded CIDRs.

```hcl
module "s3_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS to S3 through the gateway endpoint."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  prefix_list_id = aws_vpc_endpoint.s3.prefix_list_id
}
```

---

## Security Group Destination

Use `referenced_security_group_id` when traffic should be allowed to another security group.

```hcl
module "application_to_database" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow application workloads to reach the database."

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  referenced_security_group_id = module.database_sg.security_group_id
}
```

---

# AWS Region

The module supports an optional `region` argument.

When `region` is omitted, the rule uses the Region configured by the AWS provider. Specify `region` when the rule must be managed in a different Region.

```hcl
module "regional_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  region = "eu-west-1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS to the internal network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"
}
```

The module does not create or configure an AWS provider.

---

# Resource Tags

```hcl
module "https_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS to the internal network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

---

# Internet-Facing Egress

Outbound access to the internet must be explicitly requested.

```hcl
module "all_outbound" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow all outbound traffic."

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}
```

The module has no default destination.

---

# All-Protocol Egress

`ip_protocol` defaults to `-1` (all protocols). When `ip_protocol = "-1"`, `from_port` and `to_port` must be `null`.

---

# ICMP

For ICMP rules, `from_port` and `to_port` represent ICMP type and code rather than ports.

```hcl
module "icmp_egress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-egress-rule.git?ref=v2.0.1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow ICMP echo requests."

  ip_protocol = "icmp"
  from_port   = 8
  to_port     = 0

  cidr_ipv4 = "10.0.0.0/8"
}
```

For `icmpv6`, ports are optional.

---

# Validation

The module requires exactly one destination and fails during planning rather than silently selecting one.

Invalid:

```hcl
cidr_ipv4                    = "10.0.0.0/8"
referenced_security_group_id = module.database_sg.security_group_id
```

Invalid:

```hcl
cidr_ipv4                    = null
cidr_ipv6                    = null
prefix_list_id               = null
referenced_security_group_id = null
```

Each CIDR input also checks its address family:

```hcl
cidr_ipv4 = "2001:db8::/32" # invalid: IPv6 block in the IPv4 input
cidr_ipv6 = "10.0.0.0/8"    # invalid: IPv4 block in the IPv6 input
```

Ports:

* `-1`: `from_port` and `to_port` must be `null`
* `icmpv6`: ports are optional
* `tcp`, `udp`, `icmp`: both `from_port` and `to_port` are required

`ip_protocol` is case-insensitive and surrounding whitespace is ignored; the module passes the lowercase, trimmed value to AWS.

---

# Security Considerations

* No destination is assumed. `0.0.0.0/0` and `::/0` must be passed explicitly.
* Prefer `referenced_security_group_id` or a prefix list over broad CIDRs where the relationship allows it.
* Terraform removes AWS's default allow-all outbound rule when it creates a security group, so a group with no egress rule can start no connections at all.

---

# Design Principles

This module deliberately does **not** contain knowledge of subnet tiers, applications, databases, NAT gateways, VPC endpoints, or load balancers. Those are infrastructure-level concerns.

The module only establishes:

```text
Security Group
      |
      +---- Egress Rule ----> Destination
```

---

# Inputs

| Name                           | Description                                    | Type          | Default | Required |
| ------------------------------ | ---------------------------------------------- | ------------- | ------- | -------- |
| `security_group_id`            | ID of the security group receiving the rule    | `string`      | n/a     | yes      |
| `description`                  | Description explaining the purpose of the rule | `string`      | n/a     | yes      |
| `ip_protocol`                  | Protocol for the rule                          | `string`      | `"-1"`  | no       |
| `from_port`                    | Starting port or ICMP type                     | `number`      | `null`  | no       |
| `to_port`                      | Ending port or ICMP code                       | `number`      | `null`  | no       |
| `cidr_ipv4`                    | IPv4 CIDR destination                          | `string`      | `null`  | no       |
| `cidr_ipv6`                    | IPv6 CIDR destination                          | `string`      | `null`  | no       |
| `prefix_list_id`               | Prefix list destination                        | `string`      | `null`  | no       |
| `referenced_security_group_id` | Destination security group ID                  | `string`      | `null`  | no       |
| `region`                       | AWS Region where the rule is managed           | `string`      | `null`  | no       |
| `tags`                         | Tags applied to the egress rule                | `map(string)` | `{}`    | no       |

Supported protocols: `-1`, `tcp`, `udp`, `icmp`, `icmpv6`.

Exactly one of `cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id` must be provided.

---

# Outputs

| Name                | Description                                         |
| ------------------- | --------------------------------------------------- |
| `id`                | ID of the created security group egress rule        |
| `arn`               | ARN of the created security group egress rule       |
| `security_group_id` | ID of the security group receiving the egress rule  |

---

# Requirements

| Requirement  | Version             |
| ------------ | ------------------- |
| Terraform    | `>= 1.6.0`          |
| AWS Provider | `>= 6.0.0, < 7.0.0` |

---

# Module Structure

```text
terraform-aws-sg-egress-rule/
│
├── .gitignore
├── .terraform.lock.hcl
├── README.md
├── versions.tf
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
│
└── examples/
    └── complete/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Versioning

This module follows Semantic Versioning.

Current release:

```text
v2.0.1
```

In `v2.0.1`, the description is checked at plan time against AWS's rules for security group rule descriptions: letters, digits, spaces and `. _ - : / ( ) # , @ [ ] + = & ; { } ! $ *`, at most 255 characters. An apostrophe or a quote used to pass the plan and fail the apply (`InvalidParameterValue`); it now stops the plan with a clear message. Any description AWS accepts is still accepted, so no working configuration changes. `terraform test` plans the module against a mocked AWS provider (no credentials needed) to check it.

## Upgrading from v1

`v2.0.0` is a breaking release:

| v1.0.0                                                        | v2.0.0                                        |
| ------------------------------------------------------------- | --------------------------------------------- |
| `cidr_ipv4` defaulted to `0.0.0.0/0`                          | No default; exactly one destination required  |
| `cidr_ipv4` was silently ignored when a security group was set | Supplying both fails at plan time             |
| TCP/UDP without ports failed at apply                         | Fails at plan time                            |
| Output `egress_rule_id`                                       | Outputs `id`, `arn`, `security_group_id`      |

To upgrade:

1. Pass `cidr_ipv4 = "0.0.0.0/0"` explicitly anywhere the old default was relied on.
2. Remove `cidr_ipv4` from calls that set `referenced_security_group_id`.
3. Replace `module.<name>.egress_rule_id` with `module.<name>.id`.

Resource addresses are unchanged, so no rules are replaced.

The `v2.0.0` release also adds `cidr_ipv6`, `prefix_list_id`, `region`, and `tags`.

---

# License

This module is provided for reusable AWS infrastructure deployments and is intended to be consumed as a versioned Terraform module.
