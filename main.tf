terraform {
  backend "s3" {
    bucket = "statefilebucket286"
    key = "global/terraform.tfstate" // this specify the path and filename that the files in the bucket will be stored
    region = "af-south-1"
    encrypt = true
    
  }
  required_providers {
    postgresql = {
    source = "cyrilgdn/postgresql"
    version = "1.26.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    } 
  }

}

# Configuration for postgersql db provider 
# so that i can be able to handle postgresql db table within rds instance
provider "postgresql" {
  host = aws_db_instance.finbloomDB.address
  database = aws_db_instance.finbloomDB.db_name
  username = var.dbusername
  port = aws_db_instance.finbloomDB.port
  password = var.pass
  sslmode = "disable"
  connect_timeout = 15

}

# Configure the AWS Provider
provider "aws" {
  region = "af-south-1"
}

# Bucket to store state file 
resource "aws_s3_bucket" "state_file_bucket" {
  bucket = var.bucket

  tags = {
    name = "Terraform backend state file bucket"
    Environment = "Dev"
  }
}

# versioning the s3 bucket so that changes made in the file will not be overwritten but
# a new file will be created
resource "aws_s3_bucket_versioning" "stateFile_Versions" {
  bucket = aws_s3_bucket.state_file_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# s3 bucket server side encryption at resta and on fly
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_server_encryption" {
  bucket = aws_s3_bucket.state_file_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}