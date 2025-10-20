resource "aws_vpc" "finbloom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true 
  tags = {
    name = "Finbloom VPC"
    Environment = "Dev"
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnets
  vpc_id = aws_vpc.finbloom_vpc.id
  availability_zone = each.value.az_name

  cidr_block = each.value.cidr_block
  map_public_ip_on_launch = each.value.is_public ? true : false

  tags = {
    Name = "${each.key}-subnet" 
    Tier = each.value.is_public ? "public" : "private"
    Environment = "Dev"
  }
}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.finbloom_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.finbloom_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.public_igw.id
  }
}

resource "aws_route_table_association" "public_rt_a" {
  for_each = {for key, subnet in aws_subnet.subnets : key => subnet if local.subnets[key].is_public}
  
  subnet_id = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}