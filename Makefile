.PHONY: deploy deliver debug run push infra login

# Configurable environment variables
AWS_ACCOUNT_ID ?=
SUBNETS ?=
VPC_ID ?=

APP_NAME = application
ECR_HOST = $(AWS_ACCOUNT_ID).dkr.ecr.eu-central-1.amazonaws.com
ECR_REPO = ${ECR_HOST}/$(APP_NAME)
BUILD_CONTEXT = worker

.DEFAULT_GOAL := deploy

login:
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${ECR_REPO}

debug:
	docker build -t $(APP_NAME) $(BUILD_CONTEXT)
	docker run -it --rm $(APP_NAME) /bin/bash

run:
	docker build -t $(APP_NAME) $(BUILD_CONTEXT)
	docker run --rm $(APP_NAME)

push: login
ifndef AWS_ACCOUNT_ID
	$(error AWS_ACCOUNT_ID is not set)
endif
	docker build -t $(ECR_REPO):latest $(BUILD_CONTEXT)
	docker push $(ECR_REPO):latest

infra:
	aws cloudformation deploy --stack-name "my-ecs" --template infra/ecs.yaml

deliver: infra push
	aws cloudformation deploy --stack-name "my-task" --template infra/task.yaml --parameter-overrides Image="$(ECR_REPO)" VpcId="$(VPC_ID)" --capabilities CAPABILITY_IAM

deploy: deliver
	$(eval CLUSTER := $(shell aws cloudformation describe-stacks \
		--stack-name my-ecs \
		--query "Stacks[0].Outputs[?OutputKey=='ECSClusterName'].OutputValue" \
		--output text))

	$(eval TASK_SG := $(shell aws cloudformation describe-stacks \
		--stack-name my-task \
		--query "Stacks[0].Outputs[?OutputKey=='TaskSecurityGroupId'].OutputValue" \
		--output text))

	$(eval TASK_DEFINITION := $(shell aws cloudformation describe-stacks \
		--stack-name my-task \
		--query "Stacks[0].Outputs[?OutputKey=='TaskDefinitionArn'].OutputValue" \
		--output text))

	# Run the ECS task and capture task ARN
	$(eval RUN_TASK_JSON := $(shell aws ecs run-task \
		--cluster $(CLUSTER) \
		--task-definition $(TASK_DEFINITION) \
		--network-configuration "awsvpcConfiguration={subnets=[$(SUBNETS)],securityGroups=[$(TASK_SG)]}" \
		--launch-type FARGATE))
	echo $(RUN_TASK_JSON)	