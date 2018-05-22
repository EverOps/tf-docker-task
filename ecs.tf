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
        "name": "${replace(var.env, ".", "-")}-ebs_backups",
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/${var.env}-${var.name}",
                "awslogs-region": "${data.aws_region.current.name}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "environment" : [
            ${var.environment_variables}
        ]
    }
]
DEFINITION
}
