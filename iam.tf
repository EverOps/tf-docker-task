resource "aws_lambda_permission" "task-trigger" {
  statement_id  = "${replace(var.env,".", "-")}-${replace(var.name,".", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.start_task.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.schedule.arn}"
}

resource "aws_iam_role" "cloudwatch_role" {
  name = "${var.env}-${var.name}_cloudwatch_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.env}-${var.name}_cloudwatch_policy"
  role = "${aws_iam_role.cloudwatch_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "${aws_lambda_function.start_task.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.env}-${var.name}_lambda_execution_role"

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
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "${var.env}-${var.name}_lambda_execution_policy"
  role = "${aws_iam_role.lambda_execution_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ecs:*",
              "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.env}-${var.name}_ecs_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name = "${var.env}-${var.name}_ecs_execution_policy"
  role = "${aws_iam_role.ecs_execution_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["logs:*"],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}-${var.name}_ecs_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  count = "${var.task_policy == "none" ? 0 : 1}"
  name  = "${var.env}-${var.name}_ecs_task_policy"
  role  = "${aws_iam_role.ecs_task_role.id}"

  policy = "${var.task_policy}"
}

resource "aws_iam_role_policy" "ecs_task_policy_ssm_parameter" {
  count = "${var.secret_namespace == "none" ? 0 : 1}"
  name  = "${var.env}-${var.name}_ecs_task_policy"
  role  = "${aws_iam_role.ecs_task_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ssm:DescribeParameters"
        ],
        "Resource": "*"
    },
    {
        "Sid": "Stmt1482841904000",
        "Effect": "Allow",
        "Action": [
            "ssm:GetParameters"
        ],
        "Resource": [
            "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.secret_namespace}*",
        ]
    },
    {
        "Sid": "Stmt1482841948000",
        "Effect": "Allow",
        "Action": [
            "kms:Decrypt"
        ],
        "Resource": [
            "${var.kms_key_arn}"
        ]
    }
  ]
}
EOF
}
