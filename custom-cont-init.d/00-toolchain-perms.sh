#!/usr/bin/with-contenv bash
# Runs after LinuxServer's init has remapped `abc` to PUID/PGID, so this
# always matches the real runtime UID — a chown at build time wouldn't.
for dir in /opt/pyenv /opt/nvm /opt/fvm-cli /opt/fvm /opt/rustup /opt/cargo /opt/goenv /opt/gopath; do
  if [ "$(stat -c '%U' "$dir" 2>/dev/null)" != "abc" ]; then
    chown -R abc:abc "$dir"
  fi
done