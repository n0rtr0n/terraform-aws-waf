//resource "aws_iam_role" "SolutionHelperRole" {
//    name = "SolutionHelperRole"
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
//      "Sid": "SolutionHelperRoleAssumeRolePolicy"
//    }
//  ]
//}
//EOF
//    path = "/"
//}
//resource "aws_iam_role_policy" "SolutionHelperRoleSolution_Helper_Permissions" {
//    name = "SolutionHelperRoleSolution_Helper_Permissions"
//    role = "${aws_iam_role.SolutionHelperRole.id}"
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
//
//resource "aws_lambda_function" "SolutionHelper" {
//    depends_on = ["aws_s3_bucket_object.SolutionHelperZip"]
//    function_name = "SolutionHelper-${element(split("-",uuid()),0)}"
//    description = "This lambda function executes generic common tasks to support this solution."
//    role = "${aws_iam_role.SolutionHelperRole.arn}"
//    handler = "log-parser.lambda_handler"
//    s3_bucket = "solutions-${var.AWS_REGION}"
//    s3_key = "library/solution-helper/v1/solution-helper.zip"
//    runtime = "python2.7"
//    timeout = "300"
//}