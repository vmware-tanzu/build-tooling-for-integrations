FROM bash

LABEL org.opencontainers.image.source=https://github.com/vmware-tanzu/build-tooling-for-integrations

COPY ./templates/Dockerfile /
COPY ./templates/.golangci.yaml /
