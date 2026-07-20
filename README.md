# Custom Code Server for Coolify

This is a custom build of [LinuxServer's code-server](https://github.com/linuxserver/docker-code-server) tailored for deployment on [Coolify](https://coolify.io). It comes pre-installed with a versatile toolchain to support modern web and backend development directly in your browser.

## Features

- **Base Image:** `lscr.io/linuxserver/code-server:latest`
- **Node.js:** Pre-configured with `nvm` (Node Version Manager). Includes Node v22, v24, and v26, with v24 set as the default.
- **Python:** Includes Python 3, `pip`, and a global virtual environment pre-configured at `/opt/venv`.
- **Dart:** Pre-installed Dart SDK.
- **Permissions:** Custom initialization scripts ensure that `abc` (the runtime user) has correct ownership over `nvm` and `venv` directories, preventing permission denied errors inside the terminal.

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
