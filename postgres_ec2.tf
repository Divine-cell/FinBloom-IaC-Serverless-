resource "aws_instance" "psql_schema" {
    ami = var.ami
    instance_type = "t3.micro"
    for_each = {for key, subnet in aws_subnet.subnets : key => subnet if local.subnets[key].is_public}
    subnet_id = each.value.id  
    vpc_security_group_ids = [aws_security_group.psql_sg.id]
    key_name = data.aws_key_pair.bastion.key_name



    tags = {
        name = "psql_schema_instance ${each.key}"
        Environment = "Dev"
    }
    
}

data "aws_key_pair" "bastion" {
   key_name = var.key_name
}

resource "aws_security_group" "psql_sg" {
    vpc_id = aws_vpc.finbloom_vpc.id
    name = "psql_sg"
    description = "security group for postgres ec2 instance"
    
}

resource "aws_security_group_rule" "psql_sg_group_rule" {
   
    for_each = local.ec2_sg

    type = "ingress"
    from_port = each.value.from_port
    to_port = each.value.to_port
    protocol = each.value.protocol
    description = each.value.description
    security_group_id = aws_security_group.psql_sg.id
    cidr_blocks = each.value.cidr_block

}

resource "aws_security_group_rule" "psql_sg_all_rule" {
   type = "egress"
   from_port = 0
   to_port = 0
   protocol = "-1"
   description = "Allow outbound traffic to RDS"
   security_group_id = aws_security_group.psql_sg.id
   cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "psql_sg_egress_rule" {
   type = "egress"
   from_port = 5432
   to_port = 5432
   protocol = "tcp"
   description = "Allow outbound traffic to RDS"
   security_group_id = aws_security_group.psql_sg.id
   source_security_group_id = aws_security_group.rds_sg.id
}


