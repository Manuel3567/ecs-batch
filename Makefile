.PHONY: debug run push infra login
# Use environment variable for AWS Account ID (default empty)
AWS_ACCOUNT_ID ?= 

APP_NAME=application
ECR_HOST=$(AWS_ACCOUNT_ID).dkr.ecr.eu-central-1.amazonaws.com
ECR_REPO=${ECR_HOST}/$(APP_NAME)
BUILD_CONTEXT=worker

.DEFAULT_GOAL := run

login:
	aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${ECR_REPO}

debug:
	docker build -t $(APP_NAME) $(BUILD_CONTEXT)
	docker run -it --rm $(APP_NAME) /bin/bash

run:
	docker build -t $(APP_NAME) $(BUILD_CONTEXT)
	docker run --rm $(APP_NAME)

push:
ifndef AWS_ACCOUNT_ID
	$(error AWS_ACCOUNT_ID is not set)
endif
	docker build -t $(ECR_REPO):latest $(BUILD_CONTEXT)
	docker push $(ECR_REPO):latest

infra:
	aws cloudformation deploy --stack-name "my-ecs" --template infra/ecs.yaml
