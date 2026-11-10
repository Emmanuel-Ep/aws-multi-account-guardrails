resource "aws_organizations_organizational_unit" "production" {
    name = "production"
    parent_id = "r-w1d3"
}