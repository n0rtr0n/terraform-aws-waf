//
//resource "aws_iam_role" "LambdaRoleCustomResource" {
//    name = "LambdaRoleCustomResource"
//    assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "lambda.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": "LambdaRoleCustomResourceAssumeRolePolicy"
//    }
//  ]
//}
//EOF
//    path = "/"
//}
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceS3Access" {
//    name = "LambdaRoleCustomResourceS3Access"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "s3:CreateBucket",
//        "s3:GetBucketLocation",
//        "s3:GetBucketNotification",
//        "s3:GetObject",
//        "s3:ListBucket",
//        "s3:PutBucketNotification"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:s3:::${var.ACCESS_LOG_BUCKET}"
//      ]
//    }
//  ]
//}
//EOF
//}
//
//#TODO: validate this policy
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceLambdaAccess" {
//    name = "LambdaRoleCustomResourceLambdaAccess"
//  count = "${var.INCLUDE_REPUTATION_LISTS}"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "lambda:InvokeFunction",
//      "Effect": "Allow",
//      "Resource": [
//        "${aws_lambda_function.LambdaWAFReputationListsParserFunction.arn}"
//      ]
//    }
//  ]
//}
//EOF
//}
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFAccess" {
//    name = "LambdaRoleCustomResourceWAFAccess"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "waf-regional:GetWebACL",
//        "waf-regional:UpdateWebACL"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:waf-regional::${local.ACCOUNT_ID}:webacl/${aws_wafregional_web_acl.WAFWebACL.id}"
//      ]
//    }
//  ]
//}
//EOF
//}
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFRuleAccess" {
//    name = "LambdaRoleCustomResourceWAFRuleAccess"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "waf-regional:GetRule",
//        "waf-regional:GetIPSet",
//        "waf-regional:UpdateIPSet",
//        "waf-regional:UpdateWebACL"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:waf-regional:${var.AWS_REGION}:${local.ACCOUNT_ID}:rule/*"
//      ]
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFIPSetAccess" {
//    name = "LambdaRoleCustomResourceWAFIPSetAccess"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "waf-regional:GetIPSet",
//        "waf-regional:UpdateIPSet"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:waf-regional:${var.AWS_REGION}:${local.ACCOUNT_ID}:ipset/*"
//      ]
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFRateBasedRuleAccess" {
//    name = "LambdaRoleCustomResourceWAFRateBasedRuleAccess"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "waf-regional:GetRateBasedRule",
//                "waf-regional:CreateRateBasedRule",
//                "waf-regional:DeleteRateBasedRule",
//                "waf-regional:ListRateBasedRules",
//                "waf-regional:UpdateWebACL"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:waf-regional:${var.AWS_REGION}:${local.ACCOUNT_ID}:ratebasedrule/*"
//      ]
//    }
//  ]
//}
//EOF
//}
//
//
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceWAFGetChangeToken" {
//    name = "LambdaRoleCustomResourceWAFGetChangeToken"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Statement": [
//    {
//      "Action": [
//        "waf-regional:GetChangeToken"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "*"
//      ]
//    }
//  ]
//}
//EOF
//}
//
//
//resource "aws_iam_role_policy" "LambdaRoleCustomResourceLogsAccess" {
//    name = "LambdaRoleCustomResourceLogsAccess"
//    role = "${aws_iam_role.LambdaRoleCustomResource.id}"
//    policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "logs:CreateLogGroup",
//        "logs:CreateLogStream",
//        "logs:PutLogEvents"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:logs:${var.AWS_REGION}:${local.ACCOUNT_ID}:log-group:/aws/lambda/*"
//      ]
//    }
//  ]
//}
//EOF
//}
//
//#TODO:
//resource "aws_lambda_function" "LambdaWAFCustomResourceFunction" {
//    depends_on = ["aws_s3_bucket_object.CustomResourceZip"]
//    function_name = "LambdaWAFCustomResourceFunction-${element(split("-",uuid()),0)}"
//    description = "This lambda function configures the Web ACL rules based on the features enabled in the CloudFormation template."
//    role = "${aws_iam_role.LambdaRoleCustomResource.arn}"
//    handler = "custom-resource.lambda_handler"
//    s3_bucket = "solutions-${var.AWS_REGION}"
//    s3_key = "aws-waf-security-automations/v4/custom-resource.zip"
//    runtime = "python2.7"
//    memory_size = "128"
//    timeout = "300"
//}
