# image settings for the docker image name, tags and
# container name while running
IMAGE_NAME=registry.camunda.com/camunda-ci-windows
TAGS=2012 latest
NAME=windows
LATEST_QEMU_IMAGE=windows-2012.qcow2
# the qemu image to pack
QEMU_IMAGE?=$(LATEST_QEMU_IMAGE)

ifneq ($(QEMU_IMAGE),$(LATEST_QEMU_IMAGE))
	TAGS=$(word 2,$(subst -, ,$(subst ., ,$(QEMU_IMAGE))))
endif

# parent image name
FROM=$(shell head -n1 Dockerfile | cut -d " " -f 2)
# the first tag and the remaining tags split up
FIRST_TAG=$(firstword $(TAGS))
ADDITIONAL_TAGS=$(wordlist 2, $(words $(TAGS)), $(TAGS))
# the image name which will be build
IMAGE=$(IMAGE_NAME):$(FIRST_TAG)
# options to use for running the image, can be extended by FLAGS variable
OPTS=--name $(NAME) -t --privileged $(FLAGS)
# the docker command which can be configured by the DOCKER_OPTS variable
DOCKER=docker $(DOCKER_OPTS)
# the temporary Dockerfile name with replaced qemu image
DOCKERFILE_TMP=Dockerfile.tmp

# default build settings
REMOVE=true
FORCE_RM=true
NO_CACHE=false

# build the image for the first tag and tag it for additional tags
build:
	$(shell sed 's!IMAGE_NAME=.*qcow2!IMAGE_NAME=$(QEMU_IMAGE)!' Dockerfile > $(DOCKERFILE_TMP))
	$(DOCKER) build -f $(DOCKERFILE_TMP) --rm=$(REMOVE) --force-rm=$(FORCE_RM) --no-cache=$(NO_CACHE) -t $(IMAGE) .
	@for tag in $(ADDITIONAL_TAGS); do \
		$(DOCKER) tag -f $(IMAGE) $(IMAGE_NAME):$$tag; \
	done

# pull image from registry
pull:
	-$(DOCKER) pull $(IMAGE)

# pull parent image
pull-from:
	$(DOCKER) pull $(FROM)

# push container to registry
push:
	@for tag in $(TAGS); do \
		$(DOCKER) push $(IMAGE_NAME):$$tag; \
	done

# pull parent image, pull image, build image and push to repository
publish: pull-from pull build push

# run container
run: rmf
	$(DOCKER) run --rm $(OPTS) $(IMAGE)

# start container as daemon
daemon:
	$(DOCKER) run -d $(OPTS) $(IMAGE)

# start interactive container with bash
bash:
	$(DOCKER) run --rm -i $(OPTS) $(IMAGE) /bin/bash

# remove container by name
rmf:
	-$(DOCKER) rm -f $(NAME)

# remove image with all tags
rmi:
	@for tag in $(TAGS); do \
		$(DOCKER) rmi $(IMAGE_NAME):$$tag; \
	done

.PHONY: build pull pull-from push publish run daemon bash rmf rmi
