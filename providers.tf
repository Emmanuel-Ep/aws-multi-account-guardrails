terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
    source = "hashicorp/aws"
    version = "~> 5.0"
  }
}
}
provider "aws" {
    region = "ap-southeast-2"
  
}

provider "aws" {
  alias = "security"
  region = "ap-southeast-2"

assume_role {
  role_arn = "arn:aws:iam::${aws_organizations_account.security.id}:role/OrganizationAccountAccessRole"  
}
}
