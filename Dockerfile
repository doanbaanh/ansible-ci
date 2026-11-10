FROM ubuntu:26.04

ARG SOPS_VERSION=3.13.3

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    age \
    ansible \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    python3 \
    rsync \
    unzip \
 && arch="$(dpkg --print-architecture)" \
 && binary="sops-v${SOPS_VERSION}.linux.${arch}" \
 && cd /tmp \
 && curl -fsSLO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/${binary}" \
 && curl -fsSLO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.checksums.txt" \
 && grep " ${binary}$" "sops-v${SOPS_VERSION}.checksums.txt" | sha256sum -c - \
 && install -m 0755 "${binary}" /usr/local/bin/sops \
 && rm -rf /var/lib/apt/lists/* /tmp/*
