FROM bitnami/golang:1.17

LABEL org.opencontainers.image.source=https://github.com/vmware-tanzu/build-tooling-for-integrations

ENV DOCKER_CE_VERSION 5:20.10.14~3-0~debian-bullseye
ENV DOCKER_CE_CLI_VERSION 5:20.10.14~3-0~debian-bullseye
ENV CONTAINERD_VERSION 1.5.11-1
ENV GOVERSION 1.17.7

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

COPY version /version

# Uncomment after repo is public
#RUN export VERSION=$(cat /version) && go install github.com/vmware-tanzu/build-tooling-for-integrations/package-tools@${VERSION} && rm -rf /version
RUN export VERSION=$(cat /version) && go install github.com/yharish991/build-tooling/package-tools@${VERSION} && rm -rf /version

COPY package-tooling-image/build-packages.sh /build-packages.sh
ENTRYPOINT ["/build-packages.sh"]
