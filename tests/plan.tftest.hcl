# Plans the module against a mocked AWS provider. Run with "terraform test"
# (or "tofu test") from the repository root.

mock_provider "aws" {}

variables {
  security_group_id = "sg-0123456789abcdef0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "10.0.0.0/8"
}

run "every_character_aws_allows" {
  command = plan

  variables {
    description = "Letters, digits 0-9 and . _ - : / ( ) # , @ [ ] + = & ; { } ! $ *"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.this.description == var.description
    error_message = "The description should reach the rule unchanged."
  }
}

run "apostrophe_is_rejected" {
  command = plan

  variables {
    description = "Allow the isolated tier to reach the VPC's own hosts"
  }

  expect_failures = [var.description]
}

run "double_quote_is_rejected" {
  command = plan

  variables {
    description = "Allow \"quoted\" traffic"
  }

  expect_failures = [var.description]
}

run "longer_than_255_is_rejected" {
  command = plan

  variables {
    # 256 characters, one more than AWS allows.
    description = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [var.description]
}
