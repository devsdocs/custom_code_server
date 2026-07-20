# Custom Code Server for Coolify

This is a custom build of [LinuxServer's code-server](https://github.com/linuxserver/docker-code-server) tailored for deployment on [Coolify](https://coolify.io). It comes pre-installed with a versatile toolchain to support modern web and backend development directly in your browser.

## Features

- **Base Image:** `lscr.io/linuxserver/code-server:latest`
- **Build Tools:** `build-essential` (gcc, g++, make) for compiling native modules.
- **Node.js:** Multi-version via `nvm`. Includes Node v22, v24, and v26, with v24 as default. Comes with [`freebuff`](https://www.npmjs.com/package/freebuff) installed globally.
- **Python:** Multi-version via `pyenv`. Includes Python 3.12 and 3.13, with 3.13 as default.
- **Flutter/Dart:** Multi-version via `fvm`. Includes Flutter stable (with bundled Dart SDK).
- **Rust:** Multi-version via `rustup` with `rust-analyzer` included.
- **Go:** Multi-version via `goenv`. Includes Go 1.25 and 1.26, with 1.26 as default.
- **Permissions:** Custom init scripts ensure `abc` (the runtime user) owns all toolchain directories (`nvm`, `pyenv`, `fvm-cli`, `fvm`, `rustup`, `cargo`, `goenv`, `gopath`).

## Coolify Deployment Instructions

This configuration is ready to be deployed as a Docker Compose application in Coolify.

### 1. Create the Service in Coolify
1. Go to your Coolify dashboard and navigate to your Project and Environment.
2. Click **+ New Resource**.
3. Choose **Git Repository**, then select **Public Repository**.
4. Enter the URL of this public repository and proceed.
5. When prompted for the build pack, select **Docker Compose**.

### 2. Environment Variables
Coolify will automatically parse the `docker-compose.yaml` file. Go to the **Environment Variables** tab of your service and set the following:

- `PUID=1000` (Change if your host user ID is different)
- `PGID=1000` (Change if your host group ID is different)
- `TZ=Europe/Madrid` (Set to your local timezone)
- `SERVICE_PASSWORD_64_PASSWORDCODESERVER` — **You must set this manually.** This is your login password for the code-server UI. Coolify does not auto-generate service passwords for git-based deployments.
- `SERVICE_PASSWORD_SUDOCODESERVER` — **You must set this manually.** This is the sudo password inside the container.

*Note: Coolify's dynamic proxy will automatically handle routing the traffic for the `SERVICE_URL_CODESERVER_8443` variable without needing explicit port mappings in the compose file.*

### 3. Deploy
Once the configuration is reviewed, click **Deploy**. Coolify will build the Docker image locally on the server (which will take a few minutes as it downloads and installs Node, Python, and Dart) and start the container.

### 4. Access Code Server
Click on the generated URL in the Coolify interface. You will be prompted for a password. Enter the value you set for `SERVICE_PASSWORD_64_PASSWORDCODESERVER`.
