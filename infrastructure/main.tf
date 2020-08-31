terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 3.0"
}

output "placeholder" {
  value = "This is just a placeholder to get a valid output"
}
