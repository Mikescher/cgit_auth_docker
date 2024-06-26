
DOCKER_REPO_EXT=registry.blackforestbytes.com
DOCKER_NAME=mikescher/cgit_auth

build: docker

build_and_run: docker run

docker:
	docker build \
		-t $(DOCKER_NAME):latest \
		-t $(DOCKER_REPO_EXT)/$(DOCKER_NAME):latest \
		.

push:
	docker image push $(DOCKER_NAME):latest
	docker image push $(DOCKER_REPO_EXT)/$(DOCKER_NAME):latest

run:
	docker run --init --rm -it --name "cgit_auth" \
			   --env "CGIT_TITLE=My git server" \
			   --env "CGIT_DESC=Lorem Ipsum" \
			   --volume "$(shell pwd)/_repo:/cgit" \
			   --volume "$(shell pwd)/_conf:/config" \
			   --env "SSH_KEY=$(shell cat ~/.ssh/personal.pub)" \
			   --env "DEFAULT_USER=admin" \
 			   --env "DEFAULT_PASS=admin" \
 			   --env "CGIT_CACHE=0" \
 			   --env "CGIT_AUTH=1" \
			   --publish 8022:22 \
			   --publish 8080:80 \
			   $(DOCKER_NAME):latest

run-detached:
	docker run --init --rm --detach -it --name "cgit_auth" \
			   --env "CGIT_TITLE=My git server" \
			   --env "CGIT_DESC=Lorem Ipsum" \
			   --volume "$(shell pwd)/_repo:/cgit" \
			   --volume "$(shell pwd)/_conf:/config" \
			   --env "SSH_KEY=$(shell cat ~/.ssh/personal.pub)" \
			   --env "DEFAULT_USER=admin" \
 			   --env "DEFAULT_PASS=admin" \
 			   --env "CGIT_CACHE=0" \
 			   --env "CGIT_AUTH=1" \
			   --publish 8022:22 \
			   --publish 8080:80 \
			   $(DOCKER_NAME):latest
