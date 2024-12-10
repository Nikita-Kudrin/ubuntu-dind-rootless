# syntax=docker/dockerfile:1-labs

# Useful links
# https://docs.docker.com/engine/security/rootless/
# https://rootlesscontaine.rs/getting-started/common/
# https://github.com/rootless-containers/rootlesskit
# https://github.com/docker/docker-install/blob/master/rootless-install.sh
# https://get.docker.com/rootless
# https://github.com/moby/moby/blob/master/contrib/dockerd-rootless.sh
# https://github.com/moby/moby/blob/master/contrib/dockerd-rootless-setuptool.sh

FROM ubuntu:22.04

ENV XDG_RUNTIME_DIR="/home/rootless/.docker/run"
ENV PATH="/home/rootless/bin:$PATH"
ENV DOCKER_HOST="unix:///home/rootless/.docker/run/docker.sock"

ENV DOCKER_BUILDX_VERSION 0.19.2
ENV DOCKER_COMPOSE_VERSION 2.31.0

RUN set -eux; \
    apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    systemd-container \
    uidmap \
    curl \
    iptables \
    dbus-user-session \
    kmod \
    apparmor \
    iproute2 \
    fuse-overlayfs && \
    rm -rf /var/lib/apt/lists/* \
    ;

# Ubuntu's AppArmor stuff for recent Ubuntu24+ releases (use Debian Bookworm instead?)
# https://docs.docker.com/engine/security/rootless/
# https://discuss.linuxcontainers.org/t/rootless-docker-on-new-ubuntu-kernels-does-not-work/18708/4
RUN set -eux; \
    apparmor_config="/etc/apparmor.d/root.bin.rootlesskit" && \
    echo 'abi <abi/4.0>,' > "$apparmor_config" && \
    echo 'include <tunables/global>' >> "$apparmor_config" && \
    echo '"/root/bin/rootlesskit" flags=(unconfined) {' >> "$apparmor_config" && \
    echo '  userns,' >> "$apparmor_config" && \
    echo '  include if exists <local/root.bin.rootlesskit>' >> "$apparmor_config" && \
    echo '}' >> "$apparmor_config" && \
    service apparmor restart;

# Create 'rootless' user and group
RUN groupadd -r rootless && \
    useradd -m -d "/home/rootless" -g 'rootless' -u 1000 rootless && \
    mkdir "/opt/containerd" &&  chmod 777 "/opt/containerd"

# Switch to 'rootless' user
USER rootless

RUN --security=insecure set -eux; \
    curl -fsSL "https://get.docker.com/rootless" -o "$HOME/rootless.sh" && \
    chmod +x "$HOME/rootless.sh" && \
    /bin/bash "$HOME/rootless.sh"

# Docker buildx
RUN --security=insecure set -eux; \
    mkdir -p "$HOME/.docker/cli-plugins" && \
    curl -SL "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-amd64" -o "$HOME/.docker/cli-plugins/docker-buildx" && \
    chmod +x "$HOME/.docker/cli-plugins/docker-buildx"

# Docker compose
RUN --security=insecure set -eux; \
    mkdir -p "$HOME/.docker/cli-plugins" && \
    curl -SL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o "$HOME/.docker/cli-plugins/docker-compose" && \
    chmod +x "$HOME/.docker/cli-plugins/docker-compose"

# Start Docker daemon
ENTRYPOINT ["/home/rootless/bin/dockerd-rootless.sh"]
