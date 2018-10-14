resource "aws_iam_role" "LambdaRoleReputationListsParser" {
  name  = "LambdaRoleReputationListsParser"
  count = "${var.INCLUDE_REPUTATION_LISTS}"

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
      "Sid": "LambdaRoleReputationListsParserAssumeRolePolicy"
    }
  ]
}
EOF

  path = "/"
}

resource "aws_iam_role_policy" "LambdaRoleReputationListsParserCloudWatchLogs" {
  name  = "LambdaRoleReputationListsParserCloudWatchLogs"
  count = "${var.INCLUDE_REPUTATION_LISTS}"
  role  = "${aws_iam_role.LambdaRoleReputationListsParser.id}"

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

resource "aws_iam_role_policy" "LambdaRoleReputationListsParserWAFGetChangeToken" {
  name  = "LambdaRoleReputationListsParserWAFGetChangeToken"
  count = "${var.INCLUDE_REPUTATION_LISTS}"
  role  = "${aws_iam_role.LambdaRoleReputationListsParser.id}"

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

resource "aws_iam_role_policy" "LambdaRoleReputationListsParserWAFGetAndUpdateIPSet" {
  name  = "LambdaRoleReputationListsParserWAFGetAndUpdateIPSet"
  count = "${var.INCLUDE_REPUTATION_LISTS}"
  role  = "${aws_iam_role.LambdaRoleReputationListsParser.id}"

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
        "arn:aws:waf-regional:${var.AWS_REGION}:${local.ACCOUNT_ID}:ipset/${aws_wafregional_ipset.WAFReputationListsSet1.id}",
        "arn:aws:waf-regional:${var.AWS_REGION}:${local.ACCOUNT_ID}:ipset/${aws_wafregional_ipset.WAFReputationListsSet2.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaRoleReputationListsParserCloudWatchAccess" {
  name  = "LambdaRoleReputationListsParserCloudWatchAccess"
  count = "${var.INCLUDE_REPUTATION_LISTS}"
  role  = "${aws_iam_role.LambdaRoleReputationListsParser.id}"

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

resource "aws_lambda_function" "LambdaWAFReputationListsParserFunction" {
  count         = "${var.INCLUDE_REPUTATION_LISTS}"
  function_name = "LambdaWAFReputationListsParserFunction-${element(split("-",uuid()),0)}"
  description   = "This lambda function checks third-party IP reputation lists hourly for new IP ranges to block. These lists include the Spamhaus Dont Route Or Peer (DROP) and Extended Drop (EDROP) lists, the Proofpoint Emerging Threats IP list, and the Tor exit node list."
  role          = "${aws_iam_role.LambdaRoleReputationListsParser.arn}"
  handler       = "reputation-lists-parser.handler"
  s3_bucket     = "solutions-${var.AWS_REGION}"
  s3_key        = "aws-waf-security-automations/v3/reputation-lists-parser.zip"
  runtime       = "nodejs6.10"
  memory_size   = "128"
  timeout       = "300"

  environment {
    variables = {
      SEND_ANONYMOUS_USAGE_DATA = "${var.SEND_ANONYMOUS_USAGE_DATA}"
      UUID                      = "${uuid()}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "LambdaWAFReputationListsParserEventsRule" {
  depends_on          = ["aws_lambda_function.LambdaWAFReputationListsParserFunction", "aws_wafregional_ipset.WAFReputationListsSet1", "aws_wafregional_ipset.WAFReputationListsSet2"]
  count               = "${var.INCLUDE_REPUTATION_LISTS}"
  name                = "LambdaWAFReputationListsParserEventsRule-${element(split("-",uuid()),0)}"
  description         = "Security Automations - WAF Reputation Lists"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "LambdaWAFReputationListsParserEventsRuleTarget" {
  depends_on = ["aws_cloudwatch_event_rule.LambdaWAFReputationListsParserEventsRule"]
  count      = "${var.INCLUDE_REPUTATION_LISTS}"
  rule       = "${aws_cloudwatch_event_rule.LambdaWAFReputationListsParserEventsRule.name}"
  target_id  = "${aws_lambda_function.LambdaWAFReputationListsParserFunction.id}"
  arn        = "${aws_lambda_function.LambdaWAFReputationListsParserFunction.arn}"

  input = <<EOF
{
  "logType": "${var.WAF_TYPE}",
  "lists": [
    {
      "url":"https://www.spamhaus.org/drop/drop.txt"
    }, {
      "url" : "https://check.torproject.org/exit-addresses",
      "prefix":"ExitAddress "
    }, {
      "url" : "https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt"
    }
  ],
  "ipSetIds": [
    "${aws_wafregional_ipset.WAFReputationListsSet1.id}",
    "${aws_wafregional_ipset.WAFReputationListsSet2.id}"
  ]
}
EOF
}

resource "aws_lambda_permission" "LambdaInvokePermissionReputationListsParser" {
  #depends_on = ["aws_lambda_function.LambdaWAFReputationListsParserFunction", "aws_cloudwatch_event_rule.LambdaWAFReputationListsParserEventsRule"]
  count         = "${var.INCLUDE_REPUTATION_LISTS}"
  function_name = "${aws_lambda_function.LambdaWAFReputationListsParserFunction.arn}"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudWatch"
  source_arn    = "${aws_cloudwatch_event_rule.LambdaWAFReputationListsParserEventsRule.arn}"
}
