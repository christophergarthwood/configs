# **Podman Frequently Asked Questions**

[TOC]

Podman is an open-source, daemonless (background service-free) container engine designed to create, manage, and run Open Container Initiative (OCI) containers and images. Developed primarily by Red Hat, it serves as a secure, lightweight, and drop-in alternative to Docker.

## Key Features

+ Daemonless Architecture: Operates without a central background daemon (like Docker's dockerd). Containers run as independent system processes, lowering resource usage and preventing a single point of failure.Rootless by 

+ Default: Allows regular, unprivileged users to create and run containers securely without granting root access to the host system.

+ Docker Compatibility: Features a command-line interface (CLI) nearly identical to Docker. Users can often just type alias docker=podman to swap tools.

+ Kubernetes and Pod Support: Supports the management of "pods" (groups of containers sharing resources), mirroring Kubernetes environments locally.

+ Podman Desktop: Provides a graphical user interface (GUI) for Windows, macOS, and Linux to manage containers, volumes, and local Kubernetes clusters.

Reference: 

+ [Open-Source Podman Documentation](https://docs.podman.io/en/latest/)
+ [RHEL Container Documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/building_running_and_managing_containers/introduction-to-containers)

## Components

### System

#### [podman-system](https://docs.podman.io/en/latest/markdown/podman-system.1.html)

+ `podman system df` - Displays the amount of disk space used by containers, images, and volumes.

+ `podman system info` - Displays system-wide diagnostic and configuration information about Podman, including the kernel, storage driver, and security settings.

+ `podman system prune` - Removes all unused containers, pods, networks, and images to free up system storage.

+ `podman system service` - Starts a REST API service that listens for incoming requests, allowing compatibility with Docker tools and API clients.

+ `podman system connection` - Manages remote or local connection destinations for the Podman service.

+ `podman system reset` - Clears all container storage and resets your environment back to its initial state.

+ `podman system migrate` - Migrates containers and configurations to a newer version of Podman or a different OCI runtime

### Images

#### [podman-images](https://docs.podman.io/en/v5.1.2/markdown/podman-images.1.html)

To ensure you can utilize the NRL GitLab Container Register at login ensure the following in is a start up `.rc` file such as `.bashrc`:

```
echo "NRL podman registry login.";
eval "$(keychain --eval --quiet id_rsa)"
ssh-add ~/.ssh/id_rsa
source ~/.bashrc_keys
podman login --username "${NRL_REPO_USERNAME}" --password "${NRL_REPO_PAT}" registry.nrlssc.org
```

Source the location of your env vars that hold your repo username and Personal Access Token (PAT).

Displays locally stored images, their names, and their IDs. all non-dangling images in local storage images in containers storage.  

+ List all local images: 

`podman images`

OR

`podman images ls`

to see repository names, tags, image IDs, creation dates, and sizes.

+ Show all images including intermediate layers: 

`podman images -a`

OR

`podman images --all`

.List only image IDs:

`podman images -q`

OR

`podman images --quiet` 

for a clean list of IDs.

+ Show digests: 

`podman images --digests` 

to display the content digests for the images.

+ Filter results: 

`podman images --filter`

to narrow down the list by labels, dangling status, or reference patterns.

#### [Storage of Images](https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md)

Storage configuration is located at `~/.config/containers/storage.conf`, NFS not supported for daemonless / rootless mode.

Note: If the $XDG_CONFIG_HOME environment variable is set, it will look in $XDG_CONFIG_HOME/containers/storage.conf instead.

Basic structure:
```
[storage]
driver = "overlay"  # Storage driver (overlay, vfs, etc.)
graphroot = "/home/user/.local/share/containers/storage"  # Permanent data path
runroot = "/run/user/1000/containers"  # Ephemeral runtime path
```

Options shown:

+ **driver:** Specifies the storage driver (overlay is recommended).
+ **graphroot:** Permanent storage path for images and layers (defaults to /var/lib/containers/storage/ for root or ~/.local/share/containers/storage/ for rootless).
+ **runroot:** Transient runtime path cleared on reboot.

Useful commands:
```
podman info --format '{{.Store.GraphDriverName}}'
podman info --format '{{.Store.GraphRoot}}'
podman info --format '{{.Store.RunRoot}}'
```

### Network [podman-network](https://docs.podman.io/en/stable/markdown/podman-network.1.html)

podman network command manages virtual networks in Podman to control how containers communicate with each other and the outside world. In rootless Podman, networking operates without root privileges by using slirp4netns or pasta to user-space forward network traffic, allowing rootless containers to access external networks securely.Because rootless users cannot modify the host's actual network interfaces, rootless networking has distinct behaviors and limitations.

#### How Rootless Networking Works

+ UserSpace Networking - Sets up a dedicated network namespace for your containers. Traffic from the container is translated through a helper tool (like slirp4netns or pasta) to communicate through your host's network interfaces.

+ Network Creation Location - Running `podman network create` as a normal user, the network configuration files are saved inside your home directory at `~/.config/containers/networks/`.

+ Isolation - Rootless networks are unique to the user who created them. User alice cannot see or connect to networks created by user bob.

#### Key Differences vs. Rootful Podman (Good to Know)

+ Privileged Ports - Rootless containers cannot bind to host ports below 1024 by default. You must use a higher port on the host (e.g., -p 8080:80) or adjust the host's net.ipv4.ip_unprivileged_port_start sysctl setting.

+ IP Addresses - The host machine cannot directly ping a rootless container by its internal container IP address. You must map ports (-p) to access services from the host.

+ DNS Resolution - Container-to-container DNS resolution (talking to another container by its --name) only works out-of-the-box if you create and use a custom user-defined network; it does not work on the default rootless network.

#### Commands

+ `podman network create [name]` - Makes a new network. By default, it builds a bridge network with a free IP subnet.

+ `podman network ls` - Lists all available networks on your system.

+ `podman network inspect [name]` - Shows detailed configuration information for a specific network.

+ `podman network rm [name]` - Deletes an unused network.

+ `podman network connect [network] [container]` - Attaches a running container to an extra network.

+ `podman network disconnect [network] [container]` - Detaches a container from a network.

### Pods

You create groups of containers known as Pods using an orchestrator like Kubernetes or a local tool like Podman.

Podman allows you to group local containers into Pods similarly to Kubernetes without needing a full cluster.

Create an Empty Pod:

`podman pod create --name [pod-name]`

to initialize a new empty Pod with shared infrastructure namespaces.

Add Containers to the Pod: Run your container and assign it to the created Pod using the flag --pod [pod-name] 

`podman run -d --pod [pod-name] --name [container-name] [image-name] -P 8080:80`

#### [podman-pod](https://docs.podman.io/en/v5.0.1/markdown/podman-pod.1.html)

Podman pod is a collection of one or more containers that share the same network, storage, and IPC namespaces, mirroring the core concept from Kubernetes.

+ Add a container to a pod: 

`podman run -d --pod my-pod --name myWeb nginx`

+ List active pods: 

`podman pod ps`

+ Stop a pod: 

`podman pod stop my-pod`

which stops all containers within the pod.

### Containers

#### List Containers

To just list podman containers:

`podman ps -a`

To filter Podman containers by status, use the --filter (or -f) flag combined with status=<value> inside the podman ps command.

+ **Running:** - `podman ps --filter status=running`

+ **Exited:** - `podman ps -a --filter status=exited`

+ **Created:** - `podman ps -a --filter status=created`

+ **Paused:** - `podman ps -a --filter status=paused`

Podman supports filtering by created, initialized, running, stopped, paused, exited, removing, stopping, and unknown

To combine filters:

`podman ps -a --filter status=running --filter status=paused`

#### Container Build [podman-build](https://docs.podman.io/en/stable/markdown/podman-build.1.html)

podman build Builds an image using instructions from one or more Containerfiles or Dockerfiles and a specified build context directory. A Containerfile uses the same syntax as a Dockerfile internally. 

Using -f specifies the Containerfile / Dockerfile to use.

#### Podman Compose [podman-compose](https://docs.podman.io/en/latest/markdown/podman-compose.1.html)

podman compose is a built-in wrapper command in Podman that executes an external compose provider like docker-compose or podman-compose while routing traffic securely to the local Podman socket.

podman compose acts as a thin CLI bridge passing options down to an active provider.

Unlike Docker Compose, it manages multi-container definitions securely without requiring a background root daemon.

##### DOWN

`podman compose -f <compose-yaml-file> down`

##### UP

`podman compose -f <compose-yaml-file> up -d`

You can also pass an environment variable or file during compose as follows:

+ `--env, -e=env` - Set environment variables.  This option allows arbitrary environment variables that are available for the process to be launched inside of the container. If an environment variable is specified without a value, Podman checks the host environment for a value and set the variable only if it is set on the host. As a special case, if an environment variable ending in * is specified without a value, Podman searches the host environment for variables starting with the prefix and adds those variables to the container.

+ `--env-file=file` - Read in a line-delimited file of environment variables.

When Podman starts a container it actually executes the conmon program, which then executes the OCI Runtime. Conmon is the container monitor. It is a small program whose job is to watch the primary process of the container, and if the container dies, save the exit code. It also holds open the tty of the container, so that it can be attached to later. This is what allows Podman to run in detached mode (backgrounded), so Podman can exit but conmon continues to run. Each container has their own instance of conmon. Conmon waits for the container to exit, gathers and saves the exit code, and then launches a Podman process to complete the container cleanup, by shutting down the network and storage. 

#### Container Creation - [podman-create](https://docs.podman.io/en/latest/markdown/podman-create.1.html)

In Podman, you can create and manage containers using two primary commands depending on whether you want to start the container immediately or just prepare it. Because Podman is daemonless and drops root privileges by default, you can run these commands directly without needing sudo.

You can also compose a container and start it using podman-compose.

+ Run a background (detached) container:

`podman run -d --name my-web-app -p 8080:80 docker.io/library/httpd`


`podman run -d --name <container-name> -p 8080:80 <image-reference-url>`

+ Run an interactive (in terminal) container:

`podman run -it --name my-ubuntu ubuntu:latest /bin/bash`

+ Create a container without starting it:

  + `podman create --name app-container docker.io/library/alpine:latest`
  + `podman start app-container`

##### Container Start - [podman-start](https://docs.podman.io/en/stable/markdown/podman-start.1.html)

`podman start <container_name>`

`podman start <container_id>`

Additional Arguments:

+ `podman start -a -i <container-identifier>` - Attaches the container's standard streams (STDOUT, STDERR, STDIN) so you can interact with its shell.

+ `podman start -l` - Automatically starts the last created container on your system (not available on remote clients).

+ `podman ps -a -q | xargs podman start` - Queries all stopped/created container IDs and starts every single one of them.

#### Container Stop [podman-stop](https://docs.podman.io/en/stable/markdown/podman-stop.1.html)

`podman stop <container-identifier>` - command stops one or more running containers by sending a SIGTERM signal followed by a SIGKILL signal after a timeout.

Additional Arguments:

+ `podman stop --time 20 <container_identifier> (or -t 20)` - Stop a specific container and change the wait time (in seconds) before killing the container.

+ `podman stop --all (or -a)` - Stop all running containers at once.

+ `podman stop --latest or -l` - Stop only the most recently created container.

##### Container Hard Stop

Forcibly destroy all running containers.

`podman container rm -fa`

##### Container Restart - [podman-restart](https://docs.podman.io/en/v6.0.1/markdown/podman-restart.1.html)

`podman restart [options] <container-identifier>...`

Additional Arguments:

+ `-a, --all` - Restart all containers regardless of their current state.

+ `-l, --latest` - Use the last created container instead of specifying a name or ID (not available on remote clients).

+ `-t, --time` - Set the timeout (in seconds) to wait before forcibly stopping a running container.

+ `--running` - Restart only the containers that are currently running.

### Logs

#### [podman-logs](https://docs.podman.io/en/stable/markdown/podman-logs.1.html)

+ View all logs: 

`podman logs <container-name-or-id>`

+ Stream logs in real time: 

`podman logs -f <container-name-or-id>`

+ View the last N lines: 

`podman logs --tail 50 <container-name-or-id>`

+ Show timestamps: 

`podman logs --timestamps <container-name-or-id>`

+ View logs since a time:

`podman logs --since 2026-09-18T10:00:00 <container-name-or-id>`

+ Additioanl Options:

  + -l, --latest - Use the last created container automatically.

### Metrics

#### [podman-top](https://docs.podman.io/en/v5.5.0/markdown/podman-top.1.html)

The podman top command displays the running processes of a container.

`podman top [options] container [format-descriptors]`

OR

`podman container top`

Output similar to ps -ef, showing user, PID, PPID, CPU usage, and command details.

+ **Format Descriptors:** Use specifiers like pid, user, args, or seccomp to customize output columns.
+ **Host Context (h`*):** Prefix descriptors with h (e.g., hpid, huser) to see host-level PIDs and user mappings, which is especially useful for rootless containers.ps 
+ **Flags:** Pass standard ps flags (like aux), and Podman will fall back to executing ps with those flags.
+ **Latest Container:** Use the -l or --latest flag to target the most recently created container without specifying an ID or nam

#### [podman-stats](https://docs.podman.io/en/stable/markdown/podman-stats.1.html)

You can view live resource usage for Podman containers using the built-in podman-stats command or expose them for monitoring systems like Prometheus using the prometheus-podman-exporter.

+ **Live Stream:** Run podman stats to see a live stream of CPU %, memory usage, and network I/O for all running containers.

`podman stats`

+ **Single Container:** Run podman stats <container_id> to target a specific container.

`podman stats [container-id]`

+ **JSON Output:** Use podman stats --no-stream --format json to get a machine-readable payload of the current resource utilization.

`podman stats --no-stream --format json`

### Configuration - Hardened Build

1. Create a Dockerfile / Containerfile as follows:

```
# syntax=docker/dockerfile:1

# Pin to a trusted registry image digest in production.
ARG BASE_IMAGE=registry.example.com/platform/node:22-alpine@sha256:REPLACE_WITH_VERIFIED_DIGEST
FROM ${BASE_IMAGE} AS runtime

ARG APP_UID=10001
ARG APP_GID=10001
ARG APP_HOME=/opt/app
ARG APP_PORT=8080
ARG APP_ENV=production
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=0.1.0

LABEL org.opencontainers.image.title="example-podman-service" \
      org.opencontainers.image.description="Hardened example service for Podman" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://example.invalid/your-repository" \
      org.opencontainers.image.licenses="Apache-2.0" 

ENV APP_ENV="${APP_ENV}" \
    APP_HOME="${APP_HOME}" \
    APP_PORT="${APP_PORT}" \
    HOME="/nonexistent" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    NODE_ENV="production" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    TZ="UTC"

WORKDIR ${APP_HOME}

# Create a fixed, non-login account. Exact commands differ by distribution.
RUN addgroup -S -g "${APP_GID}" app \
 && adduser -S -D -H -u "${APP_UID}" -G app app \
 && mkdir -p "${APP_HOME}" /tmp /var/run/app \
 && chown -R "${APP_UID}:${APP_GID}" "${APP_HOME}" /var/run/app \
 && chmod 0750 "${APP_HOME}" \
 && chmod 1777 /tmp

# Copy only application manifest/dependencies first to improve build caching.
COPY --chown=${APP_UID}:${APP_GID} package*.json ./

# Example only: prefer lock-file-enforced install and a minimal production runtime.
RUN npm ci --omit=dev \
 && npm cache clean --force

COPY --chown=${APP_UID}:${APP_GID} . .

# Ensure source and executable permissions are as expected.
RUN chown -R "${APP_UID}:${APP_GID}" "${APP_HOME}" \
 && find "${APP_HOME}" -type d -exec chmod 0750 {} \; \
 && find "${APP_HOME}" -type f -exec chmod 0640 {} \; \
 && chmod 0750 "${APP_HOME}/server.js"

USER ${APP_UID}:${APP_GID}

EXPOSE ${APP_PORT}/tcp

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:' + process.env.APP_PORT + '/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

STOPSIGNAL SIGTERM

ENTRYPOINT ["node", "server.js"]
```

The io.containers.capabilities label can declare the capabilities an image needs; Podman recognizes it when the declared set is a subset of Podman’s default capability set. 

2. Build and network - Create an isolated bridge network first. Use a subnet that does not overlap with your LAN, VPN, or other container networks.

Execute the following command:

```
podman network create \
  --driver bridge \
  --subnet 10.89.0.0/24 \
  --gateway 10.89.0.1 \
  --dns-enabled \
  appnet
```

***Note***: Build with minimal metadata. Avoid passing credentials as build arguments: build args can be retained in image history or metadata, whereas build-time secret mounts are intended for confidential material.

3.  Build your image, execute the following command:

```
podman build \
  --pull=always \
  --network=none \
  --format=oci \
  --build-arg APP_UID=10001 \
  --build-arg APP_GID=10001 \
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg VCS_REF="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)" \
  --build-arg VERSION="0.1.0" \
  --tag localhost/example-podman-service:0.1.0 \
  --file <Dockerfile-filename> \
```

***Note***: `--network=none` prevents network use during RUN build steps. If your package manager must download dependencies, use a controlled network only for that stage, then return to `--network=none` for offline build stages. Podman’s build documentation identifies private as the default build network, while host networking exposes host-local services and is considered insecure.

4. Hardened runtime command - Create host directories as the unprivileged account that runs rootless Podman.

```
install -d -m 0750 "$HOME/containers/example/config"
install -d -m 0750 "$HOME/containers/example/data"
install -d -m 0700 "$HOME/containers/example/secrets"
```

5. Create a rootless secret rather than placing a token in ENV, an --env-file, shell history, or the image.

```
printf '%s' 'replace-with-real-secret' | \
  podman secret create example-api-token -
```

6.  Run the podman container:

```
podman run --detach \
  --name example-podman-service \
  --replace \
  --pull=never \
  --network appnet \
  --publish 127.0.0.1:8080:8080/tcp \
  --hostname example-podman-service \
  --userns=auto \
  --user 10001:10001 \
  --pid=private \
  --ipc=private \
  --uts=private \
  --cgroupns=private \
  --read-only \
  --read-only-tmpfs=true \
  --tmpfs /tmp:rw,noexec,nosuid,nodev,size=64m,mode=1777 \
  --tmpfs /var/run/app:rw,noexec,nosuid,nodev,size=16m,uid=10001,gid=10001,mode=0750 \
  --mount type=bind,src="$HOME/containers/example/config",dst=/opt/app/config,ro=true,relabel=private \
  --mount type=bind,src="$HOME/containers/example/data",dst=/opt/app/data,rw=true,relabel=private \
  --secret example-api-token,type=mount,target=/run/secrets/api-token,uid=10001,gid=10001,mode=0400 \
  --env-file "$HOME/containers/example/service.env" \
  --env APP_ENV=production \
  --env APP_PORT=8080 \
  --env TZ=UTC \
  --http-proxy=false \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt=no-new-privileges \
  --security-opt=seccomp=default \
  --security-opt=label=type:container_t \
  --pids-limit=256 \
  --memory=512m \
  --memory-reservation=384m \
  --memory-swap=512m \
  --cpus=1.00 \
  --cpu-shares=512 \
  --blkio-weight=300 \
  --ulimit nofile=4096:4096 \
  --ulimit nproc=512:512 \
  --log-driver=journald \
  --health-cmd='node -e "fetch(\"http://127.0.0.1:8080/health\").then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"' \
  --health-interval=30s \
  --health-timeout=3s \
  --health-retries=3 \
  --health-start-period=15s \
  --health-on-failure=kill \
  --restart=on-failure:5 \
  --label io.containers.autoupdate=registry \
  --label com.example.service=example-podman-service \
  localhost/example-podman-service:0.1.0
```

The command intentionally publishes only to 127.0.0.1; place a reverse proxy, firewall rule, or load balancer in front of it if external exposure is actually required. A Podman network enables DNS-based communication among containers on that network without exposing every service directly to the host.


7.  Notes

Do not use --privileged, --network=host, --pid=host, --ipc=host, broad device passthrough, or host filesystem mounts unless a documented need remains after redesign. Host IPC and host networking weaken isolation; Podman explicitly warns that host IPC grants access to host shared memory.  ***If you use any of these inputs you need to justify why.***

Keep service.env non-secret; it may contain values such as LOG_LEVEL=info, FEATURE_X=false, or endpoint hostnames. Do not include passwords, API keys, private keys, or database URLs that embed credentials.

--cap-drop=ALL is the safest baseline. Add only a capability tied to a concrete requirement.

--security-opt=seccomp=default makes the intent explicit. Validate this against your Podman version; the default seccomp profile is normally applied unless replaced. If your application needs an unusual syscall, supply a reviewed custom seccomp profile rather than disabling seccomp.

##### User Namespaces and subuid mappings in Podman

Use rootless Podman with a subordinate UID/GID range, then select --userns=keep-id when a container must write to files you own, or --userns=auto / --userns=nomap when stronger separation from your home-directory identity matters more than convenient bind-mount writes. In all cases, “root” in the container is not host root; the kernel translates container IDs through the user namespace mapping.

A Linux user namespace gives processes a separate view of numeric users and groups. A process can appear as UID 0 inside its namespace while mapping to an unprivileged UID on the host.

For rootless Podman, suppose:

+ Your host account is alice, UID/GID 1000.

+ Your allocated subordinate range is 100000–165535 (65,536 IDs).

+ A process claims UID 0 inside a container.

The default rootless mapping maps your host UID to container root. With keep-id, Podman maps your UID/GID to the same numeric values inside the container. With auto and nomap, your host account is deliberately not mapped into the container.

##### Configure subuid and subgid

An administrator must allocate non-overlapping subordinate ID ranges in both /etc/subuid and /etc/subgid. The format is:
```
# /etc/subuid
alice:100000:65536

# /etc/subgid
alice:100000:65536
```

Use `usermod` as follows:
```
sudo usermod \
  --add-subuids 100000-165535 \
  --add-subgids 100000-165535 \
  alice

```

Check the resulting alignment:
```
grep '^alice:' /etc/subuid /etc/subgid
```

Expected:
/etc/subuid:alice:100000:65536
/etc/subgid:alice:100000:65536

Ranges must be unique per user. Overlapping allocations can enable one user’s namespace mapping to collide with another’s IDs and potentially corrupt or interfere with ownership. Rootless Podman relies on these delegated ranges, together with newuidmap and newgidmap, to translate container identities safely.

After changing either allocation, stop the user’s containers and run this as that user:
```
podman system migrate
```

That refreshes Podman’s rootless state after subordinate-ID changes.

##### Choosing a Mapping Mode

`podman run --rm quay.io/podman/hello`

In the ordinary rootless mapping, container UID 0 maps to your host UID. This is convenient, but a process that is root inside the container can access host files that your regular account can access, subject to normal DAC permissions and SELinux policy.

Inspect the identify translation:

```
podman run --rm alpine id
podman run --rm alpine cat /proc/self/uid_map
```

Keep host and container ownership aligned, use keep-id for source-code mounts, local development, or an image that uses a non-root USER and must read/write your workspace.

```
podman run --rm -it \
  --userns=keep-id \
  --user "$(id -u):$(id -g)" \
  --volume "$PWD:/workspace:Z" \
  --workdir /workspace \
  docker.io/library/alpine:3.20 \
  sh
```

`keep-id` maps your current UID and GID into the container at the same numeric IDs. Podman also adds an identity entry to the container’s /etc/passwd view so programs can resolve it more naturally. It consumes all of the invoking user’s subordinate ID range, which has an operational consequence: new --userns=auto containers cannot start while a keep-id container exists for that rootless user.

If the application runs as a known UID, you can map the host caller to a different container UID/GID:

```
podman run --rm \
  --userns=keep-id:uid=10001,gid=10001 \
  --user 10001:10001 \
  docker.io/library/alpine:3.20 \
  id
```

Use this only when the image and mounted files are designed around that UID/GID.

Use automatic isolation for services, for a long-running service that does not need to write directly into files owned by your login account, use `auto`:

```
podman run --detach \
  --name isolated-service \
  --userns=auto:size=8192 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,nodev,size=64m \
  --network appnet \
  localhost/example-podman-service:0.1.0
```

`auto` assigns a unique, unused subordinate-ID range to each container and does not map your host UID into it. That means a compromised process in the container cannot simply act as your host account to access your home files. Podman estimates the needed range from the image unless you specify size; size=8192 is an example, not a universal value.

##### Bind mounts and ownership

Mounts are where user namespaces most visibly affect operations.  For writeable workspace:
```
podman run --rm -it \
  --userns=keep-id \
  --user "$(id -u):$(id -g)" \
  --mount type=bind,src="$PWD",dst=/workspace,rw,relabel=private \
  --workdir /workspace \
  docker.io/library/alpine:3.20 \
  sh
```
This avoids generated files becoming owned by a shifted subordinate ID on the host.

If you use the :U volume option, Podman recursively changes host ownership to match the container’s mapping:

```
podman run --rm \
  --userns=auto:size=8192 \
  --volume "$HOME/containers/service-data:/var/lib/app-data:Z,U" \
  localhost/example-podman-service:0.1.0
```

Use :U only on a purpose-built directory. It modifies ownership on disk and can make files awkward for the normal host user to manage afterward.
