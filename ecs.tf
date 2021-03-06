resource "aws_ecs_task_definition" "task" {
  family                   = "${replace(var.env, ".", "-")}-${replace(var.name, ".", "-")}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  task_role_arn      = "${aws_iam_role.ecs_task_role.arn}"
  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"

  container_definitions = <<DEFINITION
[
    {
        "cpu": 256,
        "essential": true,
        "image": "${var.image}",
        "memory": 512,
        "name": "${replace(var.env, ".", "-")}-${var.name}",
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/${var.env}-${var.name}",
                "awslogs-region": "${var.aws_region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment" : [
            { "name" : "AWS_REGION", "value" : "${var.ssm_parameter_region}" },
            ${var.environment_variables}
        ]
    }
]
DEFINITION
}
