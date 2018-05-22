# tf-docker-task
Terraform module that runs a ECS task on a schedule.

# Usage
Instantiate this module within your terraform code like so:
```
module "ebs-backups" {
  source = "github.com/everops/tf-docker-task"

  env        = "test"
  name       = "my-task"
  cluster_id = "my-cluster-id"
  subnet_b   = "my-subnet-b"
  subnet_c   = "my-subnet-c"
  image      = "my-docker-image:latest"
  schedule   = "0 9 * * ? *"                     # 2AM PST every day

  environment_variables = <<EOF
    { "name" : "ENVIRONMENT_VAR_A", "value" : "5" },
    { "name" : "ENVIRONMENT_VAR_B", "value" : "True" }
EOF
}
```

It is required that you specify the following items:

*env* - environment name. This value will be prepended to all resources created.
*name* - name of task. This will be used to name various resources.
*cluster_id* - ID of ECS cluster to run task in.
*subnet_b/c* - subnet IDs to run tasks in. These must be subnets of the VPC that the cluster resides in.
*schedule* - cron expression to specify how often to run this task.

---

This module has been tested to work with [this terraform module](https://github.com/everops/tf-ecs-cluster) that creates a VPC and ECS cluster to run your tasks in. You can provide your own cluster/subnets like is shown above or you can create a new cluster and VPC and run your tasks there like this:
```
module "vpc" {
  source = "github.com/everops/tf-ecs-cluster"
  env    = "test"
}

module "ebs-backups" {
  source = "github.com/everops/tf-docker-task"

  env        = "test"
  name       = "my-task"
  cluster_id = "${module.vpc.cluster_id}"
  subnet_b   = "${module.vpc.nat_subnet_b}"
  subnet_c   = "${module.vpc.nat_subnet_c}"
  image      = "my-docker-image:latest"
  schedule   = "0 9 * * ? *"                     # 2AM PST every day
EOF
}
```