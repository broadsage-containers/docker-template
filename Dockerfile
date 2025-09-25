# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage Corporation <containers@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# syntax=docker/dockerfile:1

FROM alpine:latest

RUN \
  echo "**** Install build packages ****" && \
  YQ_VERSION=v4.45.1 &&\
  wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq &&\
  chmod +x /usr/bin/yq && \
  apk add --no-cache --upgrade \
    ansible \
    bash && \
  apk del \
    alpine-release

# Copy the ansible playbooks and roles to the image
COPY ansible/ /opt/docker-template/ansible/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create workspace directory
RUN mkdir -p /workspace

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]