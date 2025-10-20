resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.finbloom_vpc.id
    name = "rds_sg"
    description = "security group for rds"
}

resource "aws_security_group_rule" "allow_rds_to_lambda" {
    type = "ingress"
    from_port = local.rds_sg.ingress.from_port
    to_port = local.rds_sg.ingress.to_port
    protocol = local.rds_sg.ingress.protocol
    security_group_id = aws_security_group.rds_sg.id
    source_security_group_id = aws_security_group.lambda_sg.id
    description = local.rds_sg.ingress.description
   
}

resource "aws_security_group_rule" "allow_rds_to_ec2" {
    type = "ingress"
    from_port = local.rds_sg.ingress.from_port
    to_port = local.rds_sg.ingress.to_port
    protocol = local.rds_sg.ingress.protocol
    security_group_id = aws_security_group.rds_sg.id
    source_security_group_id = aws_security_group.psql_sg.id
    description = local.rds_sg.ingress.description
   
}


resource "aws_security_group_rule" "allow_rds_outbound" {
   type = "egress"
   from_port = local.rds_sg.egress.from_port
   to_port = local.rds_sg.egress.to_port
   protocol = local.rds_sg.egress.protocol
   description = local.rds_sg.egress.description
   security_group_id = aws_security_group.rds_sg.id 
   source_security_group_id = aws_security_group.lambda_sg.id
}


resource "aws_db_subnet_group" "subnet_group" {
    name = "rds_subnet_group"
    subnet_ids = [for key, subnet in aws_subnet.subnets : subnet.id if !local.subnets[key].is_public]
}

resource "aws_db_parameter_group" "finbloom_pg_hba" {
    family = "postgres17"
    name = "finbloompghbagroup"
    
    parameter {
      name = "rds.force_ssl"
      value = 0
      apply_method = "pending-reboot"
    }
    parameter {
      name = "pgaudit.log_catalog"
      value = 1
      apply_method = "pending-reboot"
    }

}
resource "aws_db_instance" "finbloomDB" {
   db_name = "finbloomdb"
   allocated_storage = 20
   engine = "postgres"
   engine_version = 17.4
   instance_class = "db.t3.micro"
   port = 5432
   username = var.dbusername
   password = var.pass
   vpc_security_group_ids = [aws_security_group.rds_sg.id]
   db_subnet_group_name = aws_db_subnet_group.subnet_group.name
   skip_final_snapshot = true
   parameter_group_name = aws_db_parameter_group.finbloom_pg_hba.name
   apply_immediately = true
   publicly_accessible = true 
}