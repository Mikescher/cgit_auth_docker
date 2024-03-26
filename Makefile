
DOCKER_REPO=registry.blackforestbytes.com
DOCKER_NAME=mikescher/cgit_auth

build_and_run: build run

build:
	docker build -t $(DOCKER_REPO)/$(DOCKER_NAME):latest .

push:
	docker image push $(DOCKER_REPO)/$(DOCKER_NAME):latest

run:
	docker run --init --rm -it --name "cgit_auth" \
			   --env "CGIT_TITLE=My git server" \
			   --env "CGIT_DESC=Lorem Ipsum" \
	           --volume "$(shell pwd)/_repo:/cgit" \
	           --volume "$(shell pwd)/_conf:/config" \
			   --env "SSH_KEY=$(shell cat ~/.ssh/personal.pub)" \
			   --publish 8022:22 \
			   --publish 8080:80 \
			   $(DOCKER_REPO)/$(DOCKER_NAME):latest

run-detached:
	docker run --init --rm --detach -it --name "cgit_auth" \
			   --env "CGIT_TITLE=My git server" \
			   --env "CGIT_DESC=Lorem Ipsum" \
	           --volume "$(shell pwd)/_repo:/cgit" \
	           --volume "$(shell pwd)/_conf:/config" \
			   --env "SSH_KEY=$(shell cat ~/.ssh/personal.pub)" \
			   --publish 8022:22 \
			   --publish 8080:80 \
			   $(DOCKER_REPO)/$(DOCKER_NAME):latest
