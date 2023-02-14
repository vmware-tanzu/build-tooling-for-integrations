# Copyright 2023 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

ARG BUILDER_BASE_IMAGE=golang:1.20

FROM --platform=${BUILDPLATFORM} $BUILDER_BASE_IMAGE as base
ARG COMPONENT
WORKDIR /workspace
COPY "$COMPONENT"/go.* ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
# Install Carvel tools. The imgpkg tool is required for plugin builder publish.
RUN curl -L https://carvel.dev/install.sh | K14SIO_INSTALL_BIN_DIR=/bin bash && imgpkg version

# Linting
FROM golangci/golangci-lint:latest AS lint-base
FROM base AS lint
RUN --mount=target=. \
    --mount=from=lint-base,src=/usr/bin/golangci-lint,target=/usr/bin/golangci-lint \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/.cache/golangci-lint \
    cd $COMPONENT && golangci-lint run --config /workspace/.golangci.yaml --timeout 10m0s ./...

FROM base AS fmt
RUN --mount=target=. \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    cd $COMPONENT && go fmt ./...

FROM base AS vet
RUN --mount=target=. \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    cd $COMPONENT && go vet ./...

# Testing
FROM base AS test
RUN --mount=target=. \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    cd $COMPONENT && mkdir /out && go test -v -coverprofile=/out/cover.out ./...

# Build the manager binary
FROM base as builder
ARG TARGETOS
ARG TARGETARCH
ARG LD_FLAGS
ENV LD_FLAGS="$LD_FLAGS "'-extldflags "-static"'
RUN --mount=target=. \
    --mount=type=cache,target=/go/pkg/mod \
    cd $COMPONENT && CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GO111MODULE=on go build -o /out/manager ./main.go

# Download, extract, and install Tanzu CLI Admin Plugin Builder
FROM base AS plugin-builder
ARG PLUGINS_ADMIN="tanzu-framework-plugins-admin-linux-amd64"
ARG URL="https://github.com/vmware-tanzu/tanzu-framework/releases/latest/download/${PLUGINS_ADMIN}.tar.gz"
RUN mkdir tmp && \
    cd tmp && \
    wget ${URL} && \
    tar -xzf ${PLUGINS_ADMIN}.tar.gz --wildcards --no-anchored "builder/*/tanzu-builder-linux_amd64" && \
    rm  ${PLUGINS_ADMIN}.tar.gz && \
    builder=$(find admin-plugins/distribution/linux/amd64/cli/builder/ -name tanzu-builder-* -type f) && \
    mv ${builder} /bin/tanzu-builder && \
    cd /workspace && rm -r tmp

# Run Tanzu plugin builder and compile all plugins in the project's cmd/cli/plugin directory.
FROM plugin-builder AS plugin-compile-prep
ARG VERSION
RUN --mount=type=bind,readwrite tanzu-builder cli compile --version "${VERSION}" && \
    mkdir -p /out/plugin-artifacts && \
    cp -r artifacts /out/plugin-artifacts

# Run Tanzu plugin builder and publish all plugins in the project's cmd/cli/plugin directory.
FROM plugin-builder AS plugin-publish
ARG VERSION
ARG INPUT_ARTIFACT_DIR
ARG PLUGINS
ARG TYPE
ARG OCI_DISCOVERY_IMAGE
ARG OCI_DISTRIBUTION_IMAGE_REPOSITORY
ARG IMGPKG_USERNAME
ARG IMGPKG_PASSWORD
ENV IMGPKG_USERNAME=${IMGPKG_USERNAME} IMGPKG_PASSWORD=${IMGPKG_PASSWORD}
RUN --mount=type=bind,readwrite tanzu-builder publish --version "${VERSION}" --input-artifact-dir "${INPUT_ARTIFACT_DIR}" --plugins "${PLUGINS}" --type "${TYPE}" --oci-discovery-image "${OCI_DISCOVERY_IMAGE}" --oci-distribution-image-repository "${OCI_DISTRIBUTION_IMAGE_REPOSITORY}"

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot as image
WORKDIR /
COPY --from=builder /out/manager .
USER nonroot:nonroot

ENTRYPOINT ["/manager"]

FROM scratch AS unit-test-coverage
COPY --from=test /out/cover.out /cover.out

FROM scratch AS bin-unix
COPY --from=builder /out/manager /

FROM bin-unix AS bin-linux
FROM bin-unix AS bin-darwin

FROM scratch AS bin-windows
COPY --from=builder /out/manager /manager.exe

FROM bin-${TARGETOS} as bin

FROM scratch as plugin-compile
COPY --from=plugin-compile-prep /out/plugin-artifacts/ .
