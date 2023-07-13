FROM golang:1.19

LABEL org.opencontainers.image.source=https://github.com/vmware-tanzu/build-tooling-for-integrations

ENV DOCKER_CE_VERSION 5:24.0.4-1~debian.12~bookworm
ENV DOCKER_CE_CLI_VERSION 5:24.0.4-1~debian.12~bookworm
ENV CONTAINERD_VERSION 1.6.21-1
ENV PACKAGE_TOOLS_VERSION v0.2.0

RUN apt-get update && \
    apt-get install -y make gnupg lsb-release

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && \
    apt-get install -y \
        docker-ce=${DOCKER_CE_VERSION} \
        docker-ce-cli=${DOCKER_CE_CLI_VERSION} \
        containerd.io=${CONTAINERD_VERSION} && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://get.docker.com/ | sh

RUN go install github.com/vmware-tanzu/build-tooling-for-integrations/package-tools@${PACKAGE_TOOLS_VERSION}

COPY package-tooling-image/build-packages.sh /build-packages.sh
ENTRYPOINT ["/build-packages.sh"]
