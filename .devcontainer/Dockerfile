FROM mcr.microsoft.com/devcontainers/base:bullseye as base

RUN curl -sL https://raw.githubusercontent.com/devcontainers/features/main/src/docker-in-docker/install.sh \
| USERNAME=vscode DOCKER_DASH_COMPOSE_VERSION=v2 bash -

ENV PATH=$PATH:/usr/local/go/bin
ARG TARGETARCH
ARG GO_VERSION=1.21.4
RUN curl -sL https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz | tar -xz -C /usr/local

