resource "aws_iam_role" "LambdaRoleLogParser" {
  name  = "LambdaRoleLogParser"
  count = "${var.INCLUDE_LOG_PARSER}"

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
      "Sid": ""
    }
  ]
}
EOF

  path = "/"
}

resource "aws_iam_role_policy" "S3Access" {
  name  = "LambdaRoleLogParserS3Access"
  count = "${var.INCLUDE_LOG_PARSER}"
  role  = "${aws_iam_role.LambdaRoleLogParser.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.ACCESS_LOG_BUCKET}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "S3AccessPut" {
  name  = "LambdaRoleLogParserS3AccessPut"
  count = "${var.INCLUDE_LOG_PARSER}"
  role  = "${aws_iam_role.LambdaRoleLogParser.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.ACCESS_LOG_BUCKET}/aws-waf-security-automations-current-blocked-ips.json"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "WAFGetChangeToken" {
  name  = "LambdaRoleLogParserWAFGetChangeToken"
  count = "${var.INCLUDE_LOG_PARSER}"
  role  = "${aws_iam_role.LambdaRoleLogParser.id}"

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

resource "aws_iam_role_policy" "WAFGetAndUpdateIPSet" {
  name  = "LambdaRoleLogParserWAFGetAndUpdateIPSet"
  count = "${var.INCLUDE_LOG_PARSER}"
  role  = "${aws_iam_role.LambdaRoleLogParser.id}"

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
        "arn:aws:waf-regional::${local.ACCOUNT_ID}:ipset/${aws_wafregional_ipset.WAFBlacklistSet.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LogsAccess" {
  name  = "LambdaRoleLogParserLogsAccess"
  count = "${var.INCLUDE_LOG_PARSER}"
  role  = "${aws_iam_role.LambdaRoleLogParser.id}"

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

resource "aws_iam_role_policy" "CloudWatchAccess" {
  name  = "LambdaRoleLogParserCloudWatchAccess"
  count = "${var.INCLUDE_LOG_PARSER}"
  role  = "${aws_iam_role.LambdaRoleLogParser.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:GetMetricStatistics"
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

resource "aws_lambda_function" "LambdaWAFLogParserFunction" {
  count         = "${var.INCLUDE_LOG_PARSER}"
  function_name = "LambdaWAFLogParserFunction-${element(split("-",uuid()),0)}"
  description   = "This function parses ALB access logs to identify suspicious behavior, such as an abnormal amount of errors. It then blocks those IP addresses for a customer-defined period of time."
  role          = "${aws_iam_role.LambdaRoleLogParser.arn}"
  handler       = "log-parser.lambda_handler"

  s3_bucket = "solutions-${var.AWS_REGION}"

  s3_key      = "aws-waf-security-automations/v2/log-parser.zip"
  runtime     = "python2.7"
  memory_size = "512"
  timeout     = "300"

  environment {
    variables = {
      OUTPUT_BUCKET                                  = "${var.ACCESS_LOG_BUCKET}"
      IP_SET_ID_BLACKLIST                            = "${aws_wafregional_ipset.WAFBlacklistSet.id}"
      IP_SET_ID_AUTO_BLOCK                           = "${aws_wafregional_ipset.WAFScansProbesSet.id}"
      BLACKLIST_BLOCK_PERIOD                         = "${var.WAF_BLOCK_PERIOD}"
      ERROR_PER_MINUTE_LIMIT                         = "${var.ERROR_THRESHOLD}"
      SEND_ANONYMOUS_USAGE_DATA                      = "${var.SEND_ANONYMOUS_USAGE_DATA}"
      LIMIT_IP_ADDRESS_RANGES_PER_IP_MATCH_CONDITION = 10000
      MAX_AGE_TO_UPDATE                              = 30
      UUID                                           = "${uuid()}"
      REGION                                         = "${var.AWS_REGION}"
      LOG_TYPE                                       = "${var.WAF_TYPE}"
    }
  }
}

resource "aws_lambda_permission" "LambdaInvokePermissionLogParser" {
  count          = "${var.INCLUDE_LOG_PARSER}"
  statement_id   = "LambdaInvokePermissionLogParser"
  action         = "lambda:*"
  function_name  = "${aws_lambda_function.LambdaWAFLogParserFunction.arn}"
  principal      = "s3.amazonaws.com"
  source_account = "${local.ACCOUNT_ID}"
}
