data "archive_file" "lambdazip" {
  type        = "zip"
  output_path = "lambda-${var.name}.zip"

  source {
    content  = "${data.template_file.starttask-py.rendered}"
    filename = "starttask.py"
  }
}

data "template_file" "starttask-py" {
  template = "${file("${path.module}/lambda/starttask.py")}"

  vars {
    cluster         = "${var.cluster_id}"
    task_definition = "${aws_ecs_task_definition.task.arn}"
    subnet_b        = "${var.subnet_b}"
    subnet_c        = "${var.subnet_c}"
  }
}

resource "aws_lambda_function" "start_task" {
  filename         = "lambda-${var.name}.zip"
  function_name    = "${replace(var.env, ".", "-")}-${replace(var.name, ".", "-")}-trigger"
  role             = "${aws_iam_role.lambda_execution_role.arn}"
  handler          = "starttask.handler"
  source_code_hash = "${data.archive_file.lambdazip.output_base64sha256}"
  runtime          = "python3.6"
}
