FROM jenkins/jenkins:lts-jdk21

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      git curl unzip ansible ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ARG TERRAFORM_VERSION=1.16.5

RUN curl -fsSLo /tmp/terraform.zip \
      "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

USER jenkins
