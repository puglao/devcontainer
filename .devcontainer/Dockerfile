FROM mcr.microsoft.com/devcontainers/base:bullseye as base

ENV PATH=$PATH:/usr/local/go/bin
ARG TARGETARCH
ARG GO_VERSION=1.21.4
RUN curl -sL https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz | tar -xz -C /usr/local

