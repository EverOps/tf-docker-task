data "aws_caller_identity" "current" {}

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

variable "failed_invocation_alarm_action" {
  description = "A SNS topic ARN to broadcast to when the task fails. Defaults to empty."
  default = "none"
}

variable "environment_variables" {
  type = "string"

  # Example of how to pass in environment variables
  #   default = <<EOF
  #     { "name" : "VAR1", "value" : "VALUE1" },
  #     { "name" : "VAR2", "value" : "VALUE2" }
  # EOF
}

variable "secret_namespace" {
  description = "A SSM Parameter store secret namespace. Example, `/fargate-scheduler/ebs-backups/prod`. All secrets under this namespace will be passed into the container as environment variables at runtime. These environment variables must not collide with any that are defined in the `environment_variables` input variable"
  default     = "none"
}

variable "kms_key_arn" {
  description = "KMS key used to decrypt the SSM Parameters from the `secret_namespace` variable. Required if using secrets"
  default     = "none"
}

variable "ssm_parameter_region" {
  description = "AWS region that the SSM parameters are stored in"
  default     = "none"
}

variable "task_policy" {
  type    = "string"
  default = "none"
}
