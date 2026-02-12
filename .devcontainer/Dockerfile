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
    qpdf \
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

# Wrapper so that every Chromium invocation (Quarto, chromote, …) gets
# --disable-crash-reporter, preventing temp-file detritus in /tmp that
# triggers R CMD check NOTEs.  Quarto looks for "chromium-browser".
RUN printf '#!/bin/sh\nexec /usr/bin/chromium --disable-crash-reporter "$@"\n' \
      > /usr/bin/chromium-browser \
    && chmod +x /usr/bin/chromium-browser

# Create non-root user
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME

# Switch to non-root user for Claude CLI install
USER $USERNAME
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/dev/.local/bin:${PATH}"

ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]

# Append .bashrc.local sourcing to the default .bashrc
RUN cat >> /home/dev/.bashrc <<'EOF'

if [ -f /workspace/.devcontainer/.bashrc.local ]; then
  . /workspace/.devcontainer/.bashrc.local
fi
EOF

# .Rprofile is symlinked from .devcontainer/.Rprofile via postCreateCommand
