# Iam for lambda execution role

resource "aws_iam_role" "role_execution" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17" 
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_vpc_policy" {
  name = "lambda_vpc_policy"
  role = aws_iam_role.role_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribleSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"

        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.role_execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#lambda security group
resource "aws_security_group" "lambda_sg" {
   vpc_id = aws_vpc.finbloom_vpc.id
   name = "lambda_sg"

}

resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type = "egress"
  from_port = local.lambda_sg.egress.from_port
  to_port = local.lambda_sg.egress.to_port
  protocol = local.lambda_sg.egress.protocol
  security_group_id = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.rds_sg.id
  description = local.lambda_sg.egress.description
}

#lambda function
resource "aws_lambda_function" "Backend" {
  function_name = "Backend"
  role = aws_iam_role.role_execution.arn
  handler = "Backend/server.handler"
  source_code_hash = filebase64sha256("lambda.zip")
  runtime = "nodejs20.x"

  s3_bucket = aws_s3_bucket.Lambda_backend_zip.id
  s3_key = aws_s3_object.lambda_zip_file.key

  depends_on = [ aws_s3_bucket.Lambda_backend_zip ]

  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids = [for key, subnet in aws_subnet.subnets : subnet.id if !local.subnets[key].is_public]
  }
  
  environment {
    variables = {
      DB_HOST = aws_db_instance.finbloomDB.address
      DB_USER = var.dbusername
      DB_NAME = aws_db_instance.finbloomDB.db_name
      DB_PASS = var.pass
      DB_PORT = aws_db_instance.finbloomDB.port
    }
  }
}

# add api gateway as trigger for lambda
resource "aws_lambda_permission" "apigw_invoke" {
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.Backend.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.api_gw.execution_arn}/*/*"
}

