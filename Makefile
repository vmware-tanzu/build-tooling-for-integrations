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

.PHONY: build-main
build-main: ## Build the Docker container image for build-tooling
	docker build . --tag build-tooling

.PHONY: build-package-tooling
build-package-tooling: ## Build the Docker container image for package-tooling
	cp version package-tooling-image/version
	docker build . --tag package-tooling --file package-tooling-image/Dockerfile
	rm -rf package-tooling-image/version

.PHONY: build-all
build-all: build-main build-package-tooling ## Builds main and package-tooling

.PHONY: tag-build-tooling
tag-build-tooling: ## Tag the Docker container image for package-tooling with latest and the version
	docker tag build-tooling $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/build-tooling:$(VERSION)
	docker tag build-tooling $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/build-tooling:latest

.PHONY: tag-package-tooling
tag-package-tooling: ## Tag the Docker container image for package-tooling with latest and the version
	docker tag package-tooling $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/package-tooling:$(VERSION)
	docker tag package-tooling $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/package-tooling:latest

.PHONY: tag-all
tag-all: tag-build-tooling tag-package-tooling ## Tags build-tooling and package-tooling

.PHONY: publish-build-tooling
publish-build-tooling: ## Publish build-tooling
	docker push $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/build-tooling:$(VERSION)
	docker push $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/build-tooling:latest

.PHONY: publish-package-tooling
publish-package-tooling: ## Publish package-tooling
	docker push $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/package-tooling:$(VERSION)
	docker push $(OCI_REGISTRY_URL)/$(OCI_REGISTRY_PROJECT)/package-tooling:latest

.PHONY: publish-all
publish-all: publish-build-tooling publish-package-tooling ## Publish build-tooling and package-tooling

.PHONY: build-tag-publish-all
build-tag-publish-all: build-all tag-all publish-all ## Build, Tag and Publish build-tooling and package-tooling
