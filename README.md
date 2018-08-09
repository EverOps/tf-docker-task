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
  task_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        }
    ]
}
EOF

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
}
```

## Secret Managment
This module has the ability to pass secrets to container tasks as environment variables. Secrets can be created and pulled from AWS SSM Parameter store. There are a few prerequisites before this will work:

### Create secrets in SSM Parameter store
```
$ aws ssm put-parameter --name /fargate-scheduler/mytask/prod/MY_PASSWORD --value "Username" --type SecureString --key-id "alias/aws/ssm"
```

Use a namespaced notation when creating secrets. This will allow you to pass multiple secrets to a task. For example, if you have some secrets named as follows:  
```
/fargate-scheduler/mytask/prod/MY_PASSWORD
/fargate-scheduler/mytask/prod/MY_USERNAME
/fargate-scheduler/mytask/prod/MY_URL
```
You can pass in `/fargate-scheduler/mytask/prod/` as your secret namespace to allow your task access to all three secrets.

### Modify your docker image to pull secrets at runtime
This module has been tested and is recommended to use with [aws-env](https://github.com/Droplr/aws-env)

You can find more detailed documentation that project page but the high level is here. 

1. Put this in your `Dockerfile` somewhere
```
RUN wget https://github.com/Droplr/aws-env/raw/master/bin/aws-env-linux-amd64 -O /bin/aws-env && \
  chmod +x /bin/aws-env
```

2. Modify your `CMD` statement to invoke the `aws-env` executable before running your command. i.e
```
CMD ["/bin/bash", "-c", "eval $(aws-env) && python3 mytask.py"]
```

### Tell the terraform module which secrets you will be using.
Fill in the following variables in your module instantiation
```
module "ebs-backups" {
  source = "github.com/everops/tf-docker-task"

  ...

  secret_namespace     = "/fargate-scheduler/mytask/prod/"
  kms_key_arn          = "arn:aws:kms:us-east-1:12345678910:key/0f8bdf5d-476b-409d-9efb-81a685bfe04d"
  ssm_parameter_region = "us-east-1"
}

The module will create and associate the appropriate IAM policies that will allow your task to decrypt and access these secrets at runtime.
```