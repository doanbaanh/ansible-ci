FROM ubuntu:26.04

ARG SOPS_VERSION=3.13.3

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    age \
    ansible-core \
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

ARG YQ_VERSION=4.54.3

RUN arch="$(dpkg --print-architecture)" \
 && binary="yq_linux_${arch}" \
 && case "${arch}" in \
      amd64) checksum="129534601871538efe0ba4c5e62a34fb1d5f469bcb975c4fddeb467d82974973" ;; \
      arm64) checksum="89f69310b61b68d1245065a1241d1fc843f7a36cd6103ffd77ad987613bd1b67" ;; \
      *) exit 1 ;; \
    esac \
 && cd /tmp \
 && curl -fsSLO "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/${binary}" \
 && echo "${checksum}  ${binary}" | sha256sum -c - \
 && install -m 0755 "${binary}" /usr/local/bin/yq \
 && rm -f "${binary}"

COPY requirements.yml /tmp/requirements.yml

RUN for attempt in 1 2 3; do \
      ansible-galaxy collection install \
        -r /tmp/requirements.yml \
        -p /usr/share/ansible/collections && break; \
      [ "${attempt}" -lt 3 ] || exit 1; \
    done \
 && rm -rf /root/.ansible /tmp/*
