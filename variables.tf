# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

variable "security_group_id" {
  type        = string
  description = "The ID of the security group receiving this outbound rule."

  validation {
    condition     = trimspace(var.security_group_id) != ""
    error_message = "security_group_id must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Rule Description
# -----------------------------------------------------------------------------

variable "description" {
  type        = string
  description = "Description explaining the purpose of the egress rule."

  validation {
    condition     = trimspace(var.description) != ""
    error_message = "description must not be empty."
  }
}

# -----------------------------------------------------------------------------
# IP Protocol
# -----------------------------------------------------------------------------

variable "ip_protocol" {
  type        = string
  default     = "-1"
  description = "IP protocol for the egress rule. Supported values are -1, tcp, udp, icmp, and icmpv6."

  validation {
    condition = contains(
      [
        "-1",
        "tcp",
        "udp",
        "icmp",
        "icmpv6"
      ],
      lower(trimspace(var.ip_protocol))
    )

    error_message = "ip_protocol must be one of -1, tcp, udp, icmp, or icmpv6."
  }
}

# -----------------------------------------------------------------------------
# Starting Port
# -----------------------------------------------------------------------------

variable "from_port" {
  type        = number
  default     = null
  description = "Starting port for TCP/UDP traffic, or ICMP/ICMPv6 type. Must be null when ip_protocol is -1."
}

# -----------------------------------------------------------------------------
# Ending Port
# -----------------------------------------------------------------------------

variable "to_port" {
  type        = number
  default     = null
  description = "Ending port for TCP/UDP traffic, or ICMP/ICMPv6 code. Must be null when ip_protocol is -1."
}

# -----------------------------------------------------------------------------
# IPv4 Destination
# -----------------------------------------------------------------------------

# cidrhost() accepts both address families, so the ":" check keeps an IPv6
# block out of cidr_ipv4 (and the reverse below) at plan time rather than
# leaving AWS to reject it at apply time.

variable "cidr_ipv4" {
  type        = string
  default     = null
  description = "IPv4 CIDR block the security group may send traffic to."

  validation {
    condition = (
      var.cidr_ipv4 == null ||
      (
        trimspace(var.cidr_ipv4) != "" &&
        !strcontains(var.cidr_ipv4, ":") &&
        can(cidrhost(var.cidr_ipv4, 0))
      )
    )

    error_message = "cidr_ipv4 must be a valid IPv4 CIDR block or null."
  }
}

# -----------------------------------------------------------------------------
# IPv6 Destination
# -----------------------------------------------------------------------------

variable "cidr_ipv6" {
  type        = string
  default     = null
  description = "IPv6 CIDR block the security group may send traffic to."

  validation {
    condition = (
      var.cidr_ipv6 == null ||
      (
        trimspace(var.cidr_ipv6) != "" &&
        strcontains(var.cidr_ipv6, ":") &&
        can(cidrhost(var.cidr_ipv6, 0))
      )
    )

    error_message = "cidr_ipv6 must be a valid IPv6 CIDR block or null."
  }
}

# -----------------------------------------------------------------------------
# Prefix List Destination
# -----------------------------------------------------------------------------

variable "prefix_list_id" {
  type        = string
  default     = null
  description = "ID of the prefix list the security group may send traffic to."

  validation {
    condition = (
      var.prefix_list_id == null ||
      trimspace(var.prefix_list_id) != ""
    )

    error_message = "prefix_list_id must not be empty when provided."
  }
}

# -----------------------------------------------------------------------------
# Security Group Destination
# -----------------------------------------------------------------------------

variable "referenced_security_group_id" {
  type        = string
  default     = null
  description = "ID of the destination security group the security group may send traffic to."

  validation {
    condition = (
      var.referenced_security_group_id == null ||
      trimspace(var.referenced_security_group_id) != ""
    )

    error_message = "referenced_security_group_id must not be empty when provided."
  }
}

# -----------------------------------------------------------------------------
# AWS Region
# -----------------------------------------------------------------------------

variable "region" {
  type        = string
  default     = null
  description = "Optional AWS Region override for the security group egress rule."

  validation {
    condition = (
      var.region == null ||
      trimspace(var.region) != ""
    )

    error_message = "region must not be empty when provided."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the security group egress rule."
}