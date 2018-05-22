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

resource "aws_cloudwatch_metric_alarm" "error" {
  alarm_name          = "${var.env}-${var.name}-failedinvocation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedInvocations"
  namespace           = "AWS/Events"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alert on failed invocation for ECS ${var.env}-${var.name} task"

  dimensions {
    RuleName = "${aws_cloudwatch_event_rule.schedule.name}"
  }

  alarm_actions = "${var.failed_invocation_alarm_actions}"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.env}-${var.name}"
}
