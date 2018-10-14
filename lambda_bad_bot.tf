resource "aws_iam_role" "LambdaRoleBadBot" {
  name = "LambdaRoleBadBot"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "LambdaRoleBadBotAssumeRolePolicy"
    }
  ]
}
EOF

  path = "/"
}

resource "aws_iam_role_policy" "LambdaRoleBadBotWAFGetChangeToken" {
  name = "LambdaRoleBadBotWAFGetChangeToken"
  role = "${aws_iam_role.LambdaRoleBadBot.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "waf-regional:GetChangeToken"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaRoleBadBotWAFGetAndUpdateIPSet" {
  name = "LambdaRoleBadBotWAFGetAndUpdateIPSet"
  role = "${aws_iam_role.LambdaRoleBadBot.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "waf-regional:GetIPSet",
        "waf-regional:UpdateIPSet"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:waf-regional:${var.AWS_REGION}:${local.ACCOUNT_ID}:ipset/${aws_wafregional_ipset.WAFBadBotSet.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaRoleBadBotLogsAccess" {
  name = "LambdaRoleBadBotLogsAccess"
  role = "${aws_iam_role.LambdaRoleBadBot.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:${var.AWS_REGION}:${local.ACCOUNT_ID}:log-group:/aws/lambda/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaRoleBadBotCloudWatchAccess" {
  name = "LambdaRoleBadBotCloudWatchAccess"
  role = "${aws_iam_role.LambdaRoleBadBot.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "cloudwatch:GetMetricStatistics",
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "LambdaWAFBadBotParserFunction" {
  count         = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  function_name = "LambdaWAFBadBotParserFunction-${element(split("-",uuid()),0)}"
  description   = "This lambda function will intercepts and inspects trap endpoint requests to extract its IP address, and then add it to an AWS WAF block list."
  role          = "${aws_iam_role.LambdaRoleBadBot.arn}"
  handler       = "access-handler.lambda_handler"
  s3_bucket     = "solutions-${var.AWS_REGION}"
  s3_key        = "aws-waf-security-automations/v2/access-handler.zip"
  runtime       = "python2.7"
  memory_size   = "128"
  timeout       = "300"

  environment {
    variables = {
      IP_SET_ID_BAD_BOT         = "${aws_wafregional_ipset.WAFBadBotSet.id}"
      SEND_ANONYMOUS_USAGE_DATA = "${var.SEND_ANONYMOUS_USAGE_DATA}"
      UUID                      = "${uuid()}"
      REGION                    = "${var.AWS_REGION}"
      LOG_TYPE                  = "${var.WAF_TYPE}"
    }
  }
}

resource "aws_lambda_permission" "LambdaInvokePermissionBadBot" {
  #depends_on = ["aws_lambda_function.LambdaWAFBadBotParserFunction"]
  count         = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:*"
  function_name = "${aws_lambda_function.LambdaWAFBadBotParserFunction.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "ApiGatewayBadBot" {
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  name        = "Security Automations - WAF Bad Bot API"
  description = "API created by AWS WAF Security Automations CloudFormation template. This endpoint will be used to capture bad bots."
}

resource "aws_api_gateway_resource" "ApiGatewayBadBotResource" {
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  parent_id   = "${aws_api_gateway_rest_api.ApiGatewayBadBot.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "ApiGatewayBadBotMethod" {
  count         = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  depends_on    = ["aws_lambda_function.LambdaWAFBadBotParserFunction", "aws_lambda_permission.LambdaInvokePermissionBadBot", "aws_api_gateway_rest_api.ApiGatewayBadBot"]
  rest_api_id   = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  resource_id   = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.X-Forwarded-For" = false
  }
}

resource "aws_api_gateway_method_response" "200" {
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  resource_id = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
  http_method = "${aws_api_gateway_method.ApiGatewayBadBotMethod.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration" "ApiGatewayBadBotIntegration" {
  count                   = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  depends_on              = ["aws_api_gateway_method.ApiGatewayBadBotMethod"]
  rest_api_id             = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  resource_id             = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
  http_method             = "${aws_api_gateway_method.ApiGatewayBadBotMethod.http_method}"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.AWS_REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.LambdaWAFBadBotParserFunction.arn}/invocations"
  type                    = "AWS"

  #TODO: where did this come from?
//  request_templates = {
//    "application/json" = "{\n    \"source_ip\" : \"$input.params('X-Forwarded-For')\",\n    \"user_agent\" : \"$input.params('User-Agent')\",\n    \"bad_bot_ip_set\" : \"${aws_wafregional_ipset.WAFBadBotSet.id}\"\n}"
//  }
}

resource "aws_api_gateway_integration_response" "ApiGatewayBadBotIntegrationResponse" {
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  resource_id = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
  http_method = "${aws_api_gateway_integration.ApiGatewayBadBotIntegration.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "ApiGatewayBadBotDeployment" {
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  depends_on  = ["aws_api_gateway_method.ApiGatewayBadBotMethod", "aws_api_gateway_integration.ApiGatewayBadBotIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  stage_name  = "CFDeploymentStage"
  description = "CloudFormation Deployment Stage"
}

resource "aws_api_gateway_deployment" "ApiGatewayBadBotStage" {
  count       = "${var.INCLUDE_BAD_BOT_PROTECTION}"
  depends_on  = ["aws_api_gateway_method.ApiGatewayBadBotMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
  stage_name  = "ProdStage"
  description = "Production Stage"
}
