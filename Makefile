# Use environment variable for AWS Account ID (default empty)
AWS_ACCOUNT_ID ?= 

APP_NAME=application
ECR_REPO=$(AWS_ACCOUNT_ID).dkr.ecr.eu-central-1.amazonaws.com/$(APP_NAME)
BUILD_CONTEXT=worker

.DEFAULT_GOAL := run

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