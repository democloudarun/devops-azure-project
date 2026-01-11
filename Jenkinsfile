FROM jenkins/jenkins:lts-jdk17

USER root

# -----------------------------
# Install OS dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    unzip \
    git \
    python3 \
    python3-pip \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Docker CLI
# -----------------------------
RUN curl -fsSL https://get.docker.com | sh

# Allow Jenkins user to run Docker
RUN usermod -aG docker jenkins

# -----------------------------
# Install Terraform (stable version)
# -----------------------------
ENV TERRAFORM_VERSION=1.6.6

RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

# -----------------------------
# Install Azure CLI
# -----------------------------
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# -----------------------------
# Install Ansible (via apt, not pip)
# -----------------------------
RUN apt-get update && apt-get install -y ansible && rm -rf /var/lib/apt/lists/*

USER jenkins
