# Atlantis + Terragrunt (required by repo atlantis.yaml workflows).
# Build: docker build -t react-app-infra-atlantis:local -f docker/atlantis/Dockerfile docker/atlantis

ARG ATLANTIS_TAG=v0.31.0
FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_TAG}

USER root

ARG TERRAGRUNT_VERSION=0.69.3
RUN curl -fsSL -o /usr/local/bin/terragrunt \
  "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
  && chmod +x /usr/local/bin/terragrunt

COPY repos.yaml /etc/atlantis/repos.yaml

USER atlantis
