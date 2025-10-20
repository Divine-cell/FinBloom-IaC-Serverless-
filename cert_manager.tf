provider "aws" {
   alias = "us-east"
   region = "us-east-1"
}

resource "aws_acm_certificate" "finBloom_cert" {
   provider = aws.us-east
   domain_name = var.domain
   validation_method = "DNS"
}

resource "aws_acm_certificate" "finBloom_customdomain_cert" {
  domain_name = "transactions.finbloom.work.gd"
  validation_method = "DNS"
}



