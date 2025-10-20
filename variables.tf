variable "bucket" {
   description = "Bucket to store state file"
   
}

variable "frontend_s3_bucket" {
  description = "s3 bucket for frontend files"
}

variable "ami" {
  description = "EC2 AMI ID for Postgres"
}

variable "lambda_backend_zip" {
  description = "S3 bucket for lambda backend zip file"
}

variable "domain" {
  description = "finBoom domain name"
}


variable "dbusername" {
  description = "database username"
  type = string
}

variable "pass" {
  description = "database password"
  type = string
  sensitive = true
}

variable "key_name" {
  description = "the name of the key pair to use for the EC2 instance"
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available_zones.names, 0, 2)

  subnets = {
    public_subnet-1 = {
      cidr_block = cidrsubnet(aws_vpc.finbloom_vpc.cidr_block, 8, 0)
      is_public = true
      az_name = local.azs[0]
    }, 
    private_subnet-1 = {
      cidr_block = cidrsubnet(aws_vpc.finbloom_vpc.cidr_block, 8, 1)
      az_name = local.azs[0]
      is_public = false
    },
    public_subnet-2 = {
      cidr_block = cidrsubnet(aws_vpc.finbloom_vpc.cidr_block, 8, 2)
      az_name = local.azs[1]
      is_public = true
    },
    private_subnet-2 = {
      cidr_block = cidrsubnet(aws_vpc.finbloom_vpc.cidr_block, 8, 3)
      az_name = local.azs[1]
      is_public = false
    }
  }
}

//security group for lambda
locals {
  lambda_sg = {
    egress = {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      description = "Allow outboud traffic to RDS"
    }

  }
}

#security group for RDS
locals {
  rds_sg = {
    ingress = {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      description = "Allow inbound traffic from lambda"
    }

    egress = {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = ["0.0.0.0/0"]
      description = "Allow outbound traffic to lambda"
    }
  }
}

# psql ec2 sg
locals {
  ec2_sg = {
    ssh_ingress = {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_block = ["0.0.0.0/0"]
      description = "Allow inbound SSH traffic"
    }

    https_ingress = {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_block = ["0.0.0.0/0"]
      description = "Allow inbound HTTPS traffic"
    }

    http_ingress = {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_block = ["0.0.0.0/0"]
      description = "Allow inbound HTTP traffic"
    }

  }

  
}