resource "aws_cloudwatch_event_target" "task" {
  target_id = "${var.env}-${var.name}"
  rule      = "${aws_cloudwatch_event_rule.schedule.name}"
  arn       = "${aws_lambda_function.start_task.arn}"
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name        = "${var.env}-${var.name}"
  description = "Runs at a scheduled interval for ${var.env}-${var.name}"

  role_arn            = "${aws_iam_role.cloudwatch_role.arn}"
  schedule_expression = "cron(${var.schedule})"
}

resource "aws_cloudwatch_event_rule" "failed-task" {
  count = "${var.failed_invocation_alarm_action == "none" ? 0 : 1}"
  name        = "${var.env}-${var.name}-failed"
  description = "Alerts when a container in an ECS task exits with a return code of '1'"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ],
  "detail": {
    "clusterArn": [
      "${var.cluster_id}"
    ],
    "containers": {
      "exitCode": [
        1
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns" {
  count = "${var.failed_invocation_alarm_action == "none" ? 0 : 1}"
  rule      = "${aws_cloudwatch_event_rule.failed-task.name}"
  target_id = "${var.env}-${var.name}-SendToSNS"
  arn       = "${var.failed_invocation_alarm_action}"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.env}-${var.name}"
}
