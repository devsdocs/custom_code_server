FROM lscr.io/linuxserver/code-server:latest
SHELL ["/bin/bash", "-c"]

# Shared prerequisites
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates gnupg apt-transport-https build-essential git \
       libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
       libncursesw5-dev xz-utils libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js, multi-version via nvm ---
ENV NVM_DIR=/opt/nvm
RUN mkdir -p "$NVM_DIR" \
    && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

# Add/remove Node majors here as you need them
RUN . "$NVM_DIR/nvm.sh" \
    && nvm install 24 \
    && nvm alias default 24 \
    && ln -s "$NVM_DIR/versions/node/$(nvm version default)/bin" /opt/node-default \
    && nvm cache clear

# --- Python, multi-version via pyenv ---
ENV PYENV_ROOT=/opt/pyenv
RUN curl -fsSL https://pyenv.run | bash

# Add/remove Python versions here as you need them
# Using MAKEOPTS="-j$(nproc)" speeds up Python compilation to avoid Coolify deployment timeouts.
# Note: If your server has low RAM (e.g., <2GB), this might cause an Out-Of-Memory (OOM) error. 
# If that happens, change it to MAKEOPTS="-j1" to reduce memory usage.
RUN export PATH="$PYENV_ROOT/bin:$PATH" && eval "$(pyenv init -)" \
    && export MAKEOPTS="-j$(nproc)" \
    && pyenv install 3.13 \
    && pyenv global 3.13

# --- Flutter/Dart, multi-version via fvm ---
ENV FVM_CACHE_PATH=/opt/fvm
RUN FVM_INSTALL_DIR=/opt/fvm-cli curl -fsSL https://fvm.app/install.sh | bash

# Add/remove Flutter versions here as you need them
RUN export PATH="/opt/fvm-cli/bin:$PATH" && fvm install stable && fvm global stable

# --- Rust ---
ENV RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo
RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path \
    && /opt/cargo/bin/rustup component add rust-analyzer

# --- Go, multi-version via goenv ---
ENV GOENV_ROOT=/opt/goenv
RUN git clone https://github.com/go-nv/goenv.git "$GOENV_ROOT"

# Add/remove Go versions here as you need them
RUN export PATH="$GOENV_ROOT/bin:$PATH" && eval "$(goenv init -)" \
    && goenv install 1.26.5 \
    && goenv global 1.26.5

ENV GOPATH=/opt/gopath

# --- Global npm packages ---
RUN . "$NVM_DIR/nvm.sh" && npm install -g freebuff

# Load version managers in every code-server terminal
RUN { echo ''; \
      echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'; \
      echo 'export PATH="$PYENV_ROOT/bin:$PATH" && eval "$(pyenv init -)"'; \
      echo 'export PATH="$GOENV_ROOT/bin:$PATH" && eval "$(goenv init -)"'; \
    } >> /etc/bash.bashrc

ENV PATH="/opt/node-default/bin:${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:/opt/fvm-cli/bin:${FVM_CACHE_PATH}/default/bin:/opt/cargo/bin:${GOENV_ROOT}/shims:${GOENV_ROOT}/bin:${GOPATH}/bin:${PATH}"

COPY custom-cont-init.d/00-toolchain-perms.sh /custom-cont-init.d/00-toolchain-perms.sh
RUN chmod +x /custom-cont-init.d/00-toolchain-perms.sh