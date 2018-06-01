variable "aws_region" {
  default = "us-east-1"
}

variable "env" {
  description = "Used as a prefix to all resource names, tags, etc."
}

variable "name" {
  description = "Name of task that's being deployed"
}

variable "cluster_id" {
  description = "Cluster ID for the cluster to put the task in."
}

variable "subnet_b" {
  description = "Subnet to run task in"
}

variable "subnet_c" {
  description = "Subnet to run task in"
}

variable "image" {
  description = "Docker image URI"
}

variable "schedule" {
  description = "Cron expression that defines how often to run the backup. Default is once a day"
  default     = "0 6 ? * * *"                                                                     # 6 AM every day
}

variable "failed_invocation_alarm_actions" {
  description = "A list of SNS topics to broadcast to when the task fails. Defaults to empty."
  default     = []
}

variable "environment_variables" {
  type = "string"

  # Example of how to pass in environment variables
  #   default = <<EOF
  #     { "name" : "VAR1", "value" : "VALUE1" },
  #     { "name" : "VAR2", "value" : "VALUE2" }
  # EOF
}

variable "task_policy" {
  type    = "string"
  default = "none"
}
