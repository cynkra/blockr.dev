FROM rocker/r-ver:4.5.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libicu-dev \
    libgit2-dev \
    libsodium-dev \
    cmake \
    openssh-client \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto (using .deb, same approach as rocker)
ENV QUARTO_VERSION=1.8.27
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL -o /tmp/quarto.deb \
      "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb" && \
    dpkg -i /tmp/quarto.deb && \
    rm /tmp/quarto.deb

# Install Chromium for Quarto mermaid-format: png and shinytest2/chromote.
# Ubuntu 24.04 only ships a snap stub for chromium, which doesn't work in
# Docker. Use the xtradeb PPA which provides real arm64 + amd64 .deb builds.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg software-properties-common \
    && add-apt-repository -y ppa:xtradeb/apps \
    && apt-get update \
    && apt-get install -y --no-install-recommends chromium \
    && rm -rf /var/lib/apt/lists/*
# chromote auto-adds --no-sandbox in Docker. Quarto needs a wrapper.
RUN printf '#!/bin/sh\nexec /usr/bin/chromium --no-sandbox --disable-dev-shm-usage "$@"\n' \
    > /usr/local/bin/chromium-wrapper && chmod +x /usr/local/bin/chromium-wrapper
ENV CHROMOTE_CHROME=/usr/bin/chromium
ENV QUARTO_CHROMIUM=/usr/local/bin/chromium-wrapper

# Install Claude CLI (native installer)
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"

ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]

# .Rprofile is picked up from the workspace mount at /workspace/.Rprofile
