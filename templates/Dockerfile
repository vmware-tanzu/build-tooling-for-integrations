# Copyright 2021 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#syntax=docker/dockerfile:1.4

ARG BUILDER_BASE_IMAGE=golang:1.17

FROM $BUILDER_BASE_IMAGE as base
WORKDIR /workspace
# Copy the go source
COPY --from=component . ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Linting
FROM golangci/golangci-lint:latest AS lint-base
FROM base AS lint
RUN --mount=target=.,from=component \
    --mount=from=lint-base,src=/usr/bin/golangci-lint,target=/usr/bin/golangci-lint \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/.cache/golangci-lint \
    golangci-lint run --config /workspace/.golangci.yaml --timeout 10m0s ./...

# Testing
FROM base AS test
RUN --mount=target=.,from=component \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go test ./...

# Build the manager binary
FROM base as builder
ARG LD_FLAGS
ENV LD_FLAGS="$LD_FLAGS "'-extldflags "-static"'
RUN --mount=target=.,from=component \
    --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -o /out/manager ./main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /out/manager .
USER nonroot:nonroot

ENTRYPOINT ["/manager"]
