variable "security_group_id" {
  type        = string
  description = "The ID of the security group receiving this outbound rule."

  validation {
    condition     = trimspace(var.security_group_id) != ""
    error_message = "security_group_id must not be empty."
  }
}

variable "description" {
  type        = string
  description = "A plain-text description explaining the purpose of this outbound rule."

  validation {
    condition     = trimspace(var.description) != ""
    error_message = "description must not be empty."
  }
}

variable "ip_protocol" {
  type        = string
  default     = "-1"
  description = "IP protocol for the egress rule. Use -1 for all protocols, tcp for TCP, udp for UDP, or icmp for ICMP."

  validation {
    condition = contains([
      "-1",
      "tcp",
      "udp",
      "icmp",
      "icmpv6"
    ], lower(var.ip_protocol))

    error_message = "ip_protocol must be one of -1, tcp, udp, icmp, or icmpv6."
  }
}

variable "from_port" {
  type        = number
  default     = null
  description = "Starting port for the rule. Not required when ip_protocol is -1."
}

variable "to_port" {
  type        = number
  default     = null
  description = "Ending port for the rule. Not required when ip_protocol is -1."
}

variable "cidr_ipv4" {
  type        = string
  default     = "0.0.0.0/0"
  description = "IPv4 CIDR block receiving the outbound traffic."

  validation {
    condition = (
      var.cidr_ipv4 == null ||
      can(cidrhost(var.cidr_ipv4, 0))
    )

    error_message = "cidr_ipv4 must be a valid IPv4 CIDR block or null."
  }
}

variable "referenced_security_group_id" {
  type        = string
  default     = null
  description = "Optional security group ID receiving the outbound traffic. When provided, cidr_ipv4 is ignored."
}