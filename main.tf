resource "aws_organizations_organizational_unit" "production" {
    name = "production"
    parent_id = "r-w1d3"
}

resource "aws_organizations_organizational_unit" "security" {
    name = "security"
    parent_id = "r-w1d3"
}

resource "aws_organizations_organizational_unit" "sandbox" {
    name = "sandbox"
    parent_id = "r-w1d3"
}


import {
  to = aws_organizations_organizational_unit.development
  id = "ou-w1d3-1s02ai6o"
}

resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = "r-w1d3"
}