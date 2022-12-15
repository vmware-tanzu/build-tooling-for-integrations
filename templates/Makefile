.DEFAULT_GOAL := help

REGISTRY_PORT := 8000
REGISTRY_ENDPOINT := localhost:$(REGISTRY_PORT)
PACKAGE_PREFIX := $(REGISTRY_ENDPOINT)
REGISTRY_NAME := tanzu-integration-registry

DOCKER := docker
MAKE := make

IMG_DEFAULT_TAG := latest
IMG_VERSION_OVERRIDE ?= $(IMG_DEFAULT_TAG)
COMPONENTS ?= ""."".""

BUILD_TOOLING_CONTAINER_IMAGE ?= ghcr.io/vmware-tanzu/build-tooling
PACKAGING_CONTAINER_IMAGE ?= ghcr.io/vmware-tanzu/package-tooling
VERSION ?= v0.0.1

##
## Project Initialization Targets
##

# Bootstraps a project by creating a copy of the Tanzu build container Dockerfile
# into the project's root directory (alongside Makefile).
# This target also installs a local registry if the build is being done in a
# non-CI environment and it makes sure that the Tanzu packaging container is up to date.
bootstrap: install-registry check-copy-build-container install-package-container

install-registry:
ifneq ($(IS_CI),)
	@echo "Running in CI mode. Skipping local registry setup."
else
ifeq ($(shell $(DOCKER) ps -q -f name=$(REGISTRY_NAME) 2> /dev/null),)
	@echo "Deploying a local Docker registry for Tanzu Integrations"
	$(DOCKER) run -d -p $(REGISTRY_PORT):5000 --restart=always --name $(REGISTRY_NAME) registry:2
	@echo
endif
	@echo "Registry for Tanzu Integrations available at $(REGISTRY_ENDPOINT)"
endif

check-copy-build-container:
ifneq ("$(wildcard Dockerfile)","")
	$(eval COPY_BUILD_CONTAINER := $(shell bash -c 'read -p "There is already a Dockerfile in this project. Overwrite? [y/N]: " do_copy; echo $$do_copy'))
else
	$(eval COPY_BUILD_CONTAINER := Y)
endif
	@$(MAKE) -s COPY_BUILD_CONTAINER=$(COPY_BUILD_CONTAINER) copy-build-container

copy-build-container:
ifneq ($(filter y Y, $(COPY_BUILD_CONTAINER)),)
	@$(DOCKER) run --name tanzu-build-tooling $(BUILD_TOOLING_CONTAINER_IMAGE):$(VERSION)
	@$(DOCKER) cp tanzu-build-tooling:/Dockerfile ./Dockerfile
	@$(DOCKER) cp tanzu-build-tooling:/.golangci.yaml ./.golangci.yaml
	@echo Added Dockerfile for containerize build to $(PWD)
	@$(DOCKER) rm tanzu-build-tooling 1> /dev/null
endif

install-package-container:
	@$(DOCKER) pull $(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: bootstrap install-registry check-copy-build-container copy-build-container install-package-container


.PHONY: init
# Fetch the Dockerfile and pull image needed to build packages
init:
	docker run --rm -v ${PWD}:/workspace --entrypoint /bin/sh $(BUILD_TOOLING_CONTAINER_IMAGE):$(VERSION) -c "cp Dockerfile /workspace && cp .golangci.yaml /workspace"
	docker pull $(PACKAGING_CONTAINER_IMAGE):$(VERSION)


##
## Other Targets
##

.PHONY: all
# Run linter, tests, build and publish images and packages
all: docker-all package-vendir-sync package-bundle-generate-all package-bundle-push-all

.PHONY: docker-all
# Run linter, tests, build and publish images
docker-all: $(COMPONENTS)

.PHONY: $(COMPONENTS)
$(COMPONENTS):
	$(eval COMPONENT_PATH = $(word 1,$(subst ., ,$@)))
	$(eval IMAGE_NAME = $(word 2,$(subst ., ,$@)))
	$(eval PACKAGE_PATH = $(word 3,$(subst ., ,$@)))
	$(eval IMAGE = $(IMAGE_NAME):$(IMG_VERSION_OVERRIDE))
	$(eval DEFAULT_IMAGE = $(IMAGE_NAME):$(IMG_DEFAULT_TAG))
ifneq ($(strip $(OCI_REGISTRY)),)
	$(eval IMAGE = $(OCI_REGISTRY)/$(IMAGE_NAME):$(IMG_VERSION_OVERRIDE))
endif
	make validate-component COMPONENT_PATH=$(COMPONENT_PATH) IMAGE_NAME=$(IMAGE_NAME) PACKAGE_PATH=$(PACKAGE_PATH)
	make component-all COMPONENT_PATH=$(COMPONENT_PATH) DEFAULT_IMAGE=$(DEFAULT_IMAGE) IMAGE=$(IMAGE) PACKAGE_PATH=$(PACKAGE_PATH)

.PHONY: evaluate-component
validate-component:
ifeq ($(strip $(IMAGE_NAME)),)
	$(error Image name of the component is not set in COMPONENTS variable, check https://github.com/vmware-tanzu/build-tooling-for-integrations/blob/main/docs/build-tooling-getting-started.md#steps-to-use-the-build-tooling for more help)
else ifeq ($(strip $(PACKAGE_PATH)),)
	$(error Path to the package of the component is not set in COMPONENTS variable, check https://github.com/vmware-tanzu/build-tooling-for-integrations/blob/main/docs/build-tooling-getting-started.md#steps-to-use-the-build-tooling for more help)
endif

.PHONY: component-all
component-all:
ifeq ($(COMPONENT_PATH),)
	$(eval COMPONENT = .)
else
	$(eval COMPONENT = $(COMPONENT_PATH))
endif
	make COMPONENT=$(COMPONENT) lint
	make COMPONENT=$(COMPONENT) test
	make IMAGE=$(IMAGE) COMPONENT=$(COMPONENT) docker-build
	make IMAGE=$(IMAGE) docker-publish
	make KBLD_CONFIG_FILE_PATH=packages/$(PACKAGE_PATH)/kbld-config.yaml DEFAULT_IMAGE=$(DEFAULT_IMAGE) IMAGE=$(IMAGE) kbld-image-replace

.PHONY: docker-build
# Build docker image
docker-build:
	docker build -t $(IMAGE) -f Dockerfile --build-arg LD_FLAGS="$(LD_FLAGS)" --build-context component=$(COMPONENT) --load .

.PHONY: docker-publish
# Publish docker image
docker-publish:
	docker push $(IMAGE)

.PHONY: lint
# Run linting
lint:
ifneq ($(strip $(COMPONENT)),.)
	cp .golangci.yaml $(COMPONENT)
	docker build . -f Dockerfile --target lint --build-context component=$(COMPONENT)
	rm -rf $(COMPONENT)/.golangci.yaml
else
	docker build . -f Dockerfile --target lint --build-context component=$(COMPONENT)
endif

.PHONY: fmt
# Run go fmt against code
fmt:
	cd $(COMPONENT) && go fmt ./...

.PHONY: vet
# Perform static analysis of code
vet:
	cd $(COMPONENT) && go vet ./...

.PHONY: test
# Run tests
test: fmt vet
	docker build . -f Dockerfile --target test --build-context component=$(COMPONENT)

.PHONY: kbld-image-replace
# Add newImage in kbld-config.yaml
kbld-image-replace:
	@docker run \
	  -e OPERATIONS=kbld_replace \
	  -e KBLD_CONFIG_FILE_PATH=$(KBLD_CONFIG_FILE_PATH) \
	  -e DEFAULT_IMAGE=$(DEFAULT_IMAGE) \
	  -e NEW_IMAGE=$(IMAGE) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)


.PHONY: package-bundle-generate
# Generate package bundle for a particular package
package-bundle-generate:
	@docker run \
	  -e OPERATIONS=package_bundle_generate \
	  -e PACKAGE_NAME=$(PACKAGE_NAME) \
	  -e THICK=true \
	  -e OCI_REGISTRY=$(OCI_REGISTRY) \
	  -e PACKAGE_VERSION=$(PACKAGE_VERSION) \
	  -e PACKAGE_SUB_VERSION=$(PACKAGE_SUB_VERSION) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: package-bundle-generate-all
# Generate package bundle for all packages
package-bundle-generate-all:
	@docker run \
	  -e OPERATIONS=package_bundle_all_generate \
	  -e PACKAGE_REPOSITORY=$(PACKAGE_REPOSITORY) \
	  -e THICK=true \
	  -e OCI_REGISTRY=$(OCI_REGISTRY) \
	  -e PACKAGE_VERSION=$(PACKAGE_VERSION) \
	  -e PACKAGE_SUB_VERSION=$(PACKAGE_SUB_VERSION) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: package-bundle-push
# Push a particular package bundle
package-bundle-push:
	@docker run \
	  -e OPERATIONS=package_bundle_push \
	  -e PACKAGE_NAME=$(PACKAGE_NAME) \
	  -e OCI_REGISTRY=$(OCI_REGISTRY) \
	  -e PACKAGE_VERSION=$(PACKAGE_VERSION) \
	  -e PACKAGE_SUB_VERSION=$(PACKAGE_SUB_VERSION) \
	  -e REGISTRY_USERNAME=$(REGISTRY_USERNAME) \
	  -e REGISTRY_PASSWORD=$(REGISTRY_PASSWORD) \
	  -e REGISTRY_SERVER=$(REGISTRY_SERVER) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: package-bundle-push-all
# Push all package bundles
package-bundle-push-all:
	@docker run \
	  -e OPERATIONS=package_bundle_all_push \
	  -e PACKAGE_REPOSITORY=$(PACKAGE_REPOSITORY) \
	  -e OCI_REGISTRY=$(OCI_REGISTRY) \
	  -e PACKAGE_VERSION=$(PACKAGE_VERSION) \
	  -e PACKAGE_SUB_VERSION=$(PACKAGE_SUB_VERSION) \
	  -e REGISTRY_USERNAME=$(REGISTRY_USERNAME) \
	  -e REGISTRY_PASSWORD=$(REGISTRY_PASSWORD) \
	  -e REGISTRY_SERVER=$(REGISTRY_SERVER) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: repo-bundle-generate
# Generate repo bundle
repo-bundle-generate:
	@docker run \
	  -e OPERATIONS=repo_bundle_generate \
	  -e PACKAGE_REPOSITORY=$(PACKAGE_REPOSITORY) \
	  -e OCI_REGISTRY=$(OCI_REGISTRY) \
	  -e REPO_BUNDLE_VERSION=$(REPO_BUNDLE_VERSION) \
	  -e REPO_BUNDLE_SUB_VERSION=$(REPO_BUNDLE_SUB_VERSION) \
	  -e PACKAGE_VALUES_FILE=$(PACKAGE_VALUES_FILE) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: repo-bundle-push
# Push repo bundle
repo-bundle-push:
	@docker run \
	  -e OPERATIONS=repo_bundle_push \
	  -e PACKAGE_REPOSITORY=$(PACKAGE_REPOSITORY) \
	  -e OCI_REGISTRY=$(OCI_REGISTRY) \
	  -e REPO_BUNDLE_VERSION=$(REPO_BUNDLE_VERSION) \
	  -e REPO_BUNDLE_SUB_VERSION=$(REPO_BUNDLE_SUB_VERSION) \
	  -e REGISTRY_USERNAME=$(REGISTRY_USERNAME) \
	  -e REGISTRY_PASSWORD=$(REGISTRY_PASSWORD) \
	  -e REGISTRY_SERVER=$(REGISTRY_SERVER) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: package-vendir-sync
# Performs vendir sync on each package
package-vendir-sync:
	@docker run \
	  -e OPERATIONS=vendir_sync \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: help
# Show help
help:
	@cat $(MAKEFILE_LIST) | docker run --rm -i xanders/make-help
