# -----------------------------------------------------------------------------
# Normalised Protocol
# -----------------------------------------------------------------------------
# The ip_protocol validation accepts any letter case and surrounding
# whitespace. The provider compares protocols case-insensitively but does not
# trim whitespace, and the port precondition compares exact values. Normalising
# once here keeps the resource, the precondition and the validation in
# agreement. "TCP" and "tcp" are semantically equal to the provider, so existing
# callers see no plan difference.
# -----------------------------------------------------------------------------

locals {
  ip_protocol = lower(trimspace(var.ip_protocol))
}
