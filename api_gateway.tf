resource "aws_apigatewayv2_api" "api_gw" {
   name = "FinbloonApi"
   protocol_type = "HTTP"

   cors_configuration {
     allow_origins = ["https://www.finbloom.work.gd"]
     allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
     allow_headers = ["Content-Type", "Authorization", "X-Requested-With"]
     expose_headers = ["Content-Type"]
     max_age = 3600

   }
}

# creating custom domain for api gateway
resource "aws_apigatewayv2_domain_name" "ap_domain_name" {
   domain_name = "transactions.finbloom.work.gd"
   domain_name_configuration {
       certificate_arn = aws_acm_certificate.finBloom_customdomain_cert.arn
       endpoint_type = "REGIONAL"
       security_policy = "TLS_1_2"
   }
}

resource "aws_apigatewayv2_stage" "api_stage" {
   api_id = aws_apigatewayv2_api.api_gw.id
   name = "$default"
    auto_deploy = true
}

# mapping api to custom domain
resource "aws_apigatewayv2_api_mapping" "api_mapping" {
   api_id = aws_apigatewayv2_api.api_gw.id
   domain_name = aws_apigatewayv2_domain_name.ap_domain_name.id
   stage = aws_apigatewayv2_stage.api_stage.id
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id = aws_apigatewayv2_api.api_gw.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.Backend.arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# creating route for api gateway to trigger lambda function specifically for /api/transactions endpoint
resource "aws_apigatewayv2_route" "api_route" {
  api_id = aws_apigatewayv2_api.api_gw.id
  route_key = "ANY /api/transactions"
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}


resource "aws_apigatewayv2_route" "api_options" {
  api_id = aws_apigatewayv2_api.api_gw.id
  route_key = "OPTIONS /api/transactions"
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}
# creating route to catch all other requests and send to lambda
resource "aws_apigatewayv2_route" "api_root" {
  api_id = aws_apigatewayv2_api.api_gw.id
  route_key = "ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}