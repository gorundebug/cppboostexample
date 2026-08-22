# Local dependency proxy

The optional shared Nexus instance caches artifacts downloaded
from public Go, npm, PyPI, Cargo, Helm, Maven Central and Docker Hub registries.
It is a network package proxy, not a compiler or BuildKit cache.

```bash
# Configure one global data directory in your shell:
export SERVICEGEN_DEPENDENCY_PROXY_DIR="$HOME/.servicegen/dependency-proxy"

# First start only, after reading the EULA:
make SERVICEGEN_NEXUS_ACCEPT_EULA=true dependency-cache-up

# Later starts; the container remains running between project builds:
make dependency-cache-up

# Host package managers:
eval "$(make -s dependency-cache-env)"
make build

# Or build Docker images through the proxy:
make dependency-cache-docker-build
```

The first command is required once for a new cache directory after reading the
[Nexus Community Edition EULA](https://links.sonatype.com/products/nxrm/ce-eula).
Later starts do not need the flag.

Downloaded artifacts are stored under
`$SERVICEGEN_DEPENDENCY_PROXY_DIR/nexus`. When this variable is present,
generated Make targets automatically route all
supported host and Docker package downloads through that Nexus instance. The
container has `restart: unless-stopped`; ordinary `docker-down` commands do not
stop it. Use `dependency-cache-down` explicitly when it should stop, and
`dependency-cache-clean` to remove its data. Without the variable the proxy is
disabled, `dependency-cache-up` refuses to start, and builds use their normal
upstreams.

Host package managers use `localhost`. Container builds use the stable
`host.docker.internal` name. Docker Desktop supplies it natively; generated
Docker/Compose commands add the `host-gateway` mapping required by Docker
Engine on Linux. On Linux the proxy launcher therefore binds the published
ports to the host bridge (`0.0.0.0` by default); use the host firewall or set
`SERVICEGEN_NEXUS_BIND_HOST` explicitly when tighter exposure is required.

Docker image proxying is exposed on port 18083, but Docker Desktop/Engine must
be configured explicitly to trust/use that registry or registry mirror. The
generated project never edits daemon settings. A Compose file also cannot cache
arbitrary Git clones or direct GitHub release downloads; pinned C++
Git/FetchContent sources keep their existing versioned source cache.