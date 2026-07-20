FROM lscr.io/linuxserver/code-server:latest
SHELL ["/bin/bash", "-c"]

# Shared prerequisites
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates gnupg apt-transport-https build-essential \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js, multi-version via nvm ---
ENV NVM_DIR=/opt/nvm
RUN mkdir -p "$NVM_DIR" \
    && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

# Add/remove Node majors here as you need them
RUN . "$NVM_DIR/nvm.sh" \
    && nvm install 22 \
    && nvm install 24 \
    && nvm install 26 \
    && nvm alias default 24 \
    && ln -s "$NVM_DIR/versions/node/$(nvm version default)/bin" /opt/node-default \
    && nvm cache clear

# Load nvm (and `nvm use`) in every code-server terminal
RUN echo '' >> /etc/bash.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /etc/bash.bashrc

# --- Python ---
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip python3-venv \
    && python3 -m venv /opt/venv \
    && rm -rf /var/lib/apt/lists/*

# --- Dart ---
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg \
    && echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64,arm64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' > /etc/apt/sources.list.d/dart_stable.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends dart \
    && rm -rf /var/lib/apt/lists/*

# --- Global npm packages ---
RUN . "$NVM_DIR/nvm.sh" && npm install -g freebuff

ENV PATH="/opt/node-default/bin:/opt/venv/bin:/usr/lib/dart/bin:${PATH}"

COPY custom-cont-init.d/00-toolchain-perms.sh /custom-cont-init.d/00-toolchain-perms.sh
RUN chmod +x /custom-cont-init.d/00-toolchain-perms.sh