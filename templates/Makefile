IMG_DEFAULT_TAG := latest
IMG_VERSION_OVERRIDE ?= $(IMG_DEFAULT_TAG)
COMPONENTS ?= ""."".""

BUILD_TOOLING_CONTAINER_IMAGE ?= ghcr.io/vmware-tanzu/build-tooling
PACKAGING_CONTAINER_IMAGE ?= ghcr.io/vmware-tanzu/package-tooling
VERSION ?= latest

.PHONY: init
init: ## Fetch the Dockerfile and pull image needed to build packages
	docker run --rm -v ${PWD}:/workspace --entrypoint /bin/sh $(BUILD_TOOLING_CONTAINER_IMAGE):$(VERSION) -c "cp Dockerfile /workspace && cp .golangci.yaml /workspace"
    docker pull $(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: all
all: docker-all package-vendir-sync package-bundle-generate-all package-bundle-push-all ## Run linter, tests, build and publish images and packages

.PHONY: docker-all
docker-all: $(COMPONENTS) ## Run linter, tests, build and publish images

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
	make component-all COMPONENT_PATH=$(COMPONENT_PATH) DEFAULT_IMAGE=$(DEFAULT_IMAGE) IMAGE=$(IMAGE) PACKAGE_PATH=$(PACKAGE_PATH)

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
docker-build: ## Build docker image
	docker build -t $(IMAGE) -f Dockerfile --build-arg LD_FLAGS="$(LD_FLAGS)" --build-context component=$(COMPONENT) --load .

.PHONY: docker-publish
docker-publish: ## Publish docker image
	docker push $(IMAGE)

.PHONY: lint
lint: ## Run linting
ifneq ($(strip $(COMPONENT)),.)
	cp .golangci.yaml $(COMPONENT)
	docker build . -f Dockerfile --target lint --build-context component=$(COMPONENT)
	rm -rf $(COMPONENT)/.golangci.yaml
else
	docker build . -f Dockerfile --target lint --build-context component=$(COMPONENT)
endif

.PHONY: fmt
fmt: ## Run go fmt against code
	cd $(COMPONENT) && go fmt ./...

.PHONY: vet
vet: ## Perform static analysis of code
	cd $(COMPONENT) && go vet ./...

.PHONY: test
test: fmt vet ## Run tests
	docker build . -f Dockerfile --target test --build-context component=$(COMPONENT)

.PHONY: kbld-image-replace
kbld-image-replace: ## Add newImage in kbld-config.yaml
	@docker run \
	  -e OPERATIONS=kbld_replace \
	  -e KBLD_CONFIG_FILE_PATH=$(KBLD_CONFIG_FILE_PATH) \
	  -e DEFAULT_IMAGE=$(DEFAULT_IMAGE) \
	  -e NEW_IMAGE=$(IMAGE) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)


.PHONY: package-bundle-generate
package-bundle-generate: ## Generate package bundle for a particular package
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
package-bundle-generate-all: ## Generate package bundle for all packages
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
package-bundle-push: ## Push a particular package bundle
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
package-bundle-push-all: ## Push all package bundles
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
repo-bundle-generate: ## Generate repo bundle
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
repo-bundle-push: ## Push repo bundle
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
package-vendir-sync: ## Performs vendir sync on each package
	@docker run \
	  -e OPERATIONS=vendir_sync \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $(PWD):/workspace \
		$(PACKAGING_CONTAINER_IMAGE):$(VERSION)

.PHONY: help
help: ## Show help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
