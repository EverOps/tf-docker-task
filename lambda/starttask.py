import boto3

def handler(event, context):

    ecs = boto3.client('ecs')

    response = ecs.run_task(
        cluster='${cluster}',
        taskDefinition='${task_definition}',
        count=1,
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [
                    '${subnet_b}',
                    '${subnet_c}'
                ],
            }
        }
    )