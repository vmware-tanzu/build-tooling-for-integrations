##### Config

# Use a custom config file: make oci-config=custom.env build
oci-config ?= oci.env
include $(oci-config)
export $(shell sed 's/=.*//' $(oci-config))

##### Tasks

.PHONY: help
help: ## Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: oci-login
oci-login: ## Login to the OCI Registry
	@echo $(OCI_REGISTRY_PASSWORD) | docker login $(OCI_REGISTRY_URL) --username $(OCI_REGISTRY_USERNAME) --password-stdin

.PHONY: build
build: ## Build the Docker container image
	docker build --tag $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/$(IMAGE_NAME):$(DOCKER_IMAGE_TAG) --file $(DOCKERFILE_PATH)

.PHONY: publish
publish: ## Publish the container image
	docker push $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/$(IMAGE_NAME):$(DOCKER_IMAGE_TAG)
