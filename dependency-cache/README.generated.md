# Local dependency proxy

The optional shared Nexus instance caches artifacts downloaded
from public Go, npm, PyPI, Cargo, Helm, Maven Central, APT and Docker Hub registries,
plus immutable GitHub/GitLab archives and release assets used by generated
builds.
The companion persistent Git mirror caches smart-HTTP clones used by CPM and
other Git-based fetchers, which a package proxy cannot cache. Neither service
is a compiler or BuildKit cache.

```bash
# Configure one global data directory in your shell:
export DEPENDENCY_PROXY_DIR="$HOME/.servicegen/dependency-proxy"

# First start only, after reading the EULA:
make DEPENDENCY_PROXY_ACCEPT_EULA=true dependency-cache-up

# Later starts; the container remains running between project builds:
make dependency-cache-up

# Force every existing bare Git mirror to fetch current refs now:
make dependency-cache-refresh

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
`$DEPENDENCY_PROXY_DIR/nexus`; bare Git mirrors are stored under
`$DEPENDENCY_PROXY_DIR/git-mirror`. When this variable is present,
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
`DEPENDENCY_PROXY_BIND_HOST` explicitly when tighter exposure is required.

Docker image proxying is exposed on port 18083. When proxy mode is enabled,
generated service builds pass `DEPENDENCY_DOCKER_REGISTRY` to every language's
Dockerfile, so base images are resolved through Nexus without changing Docker
Desktop/Engine daemon settings. Without proxy mode the value remains
`docker.io`. Pinned C++ sources use immutable archives through host-specific raw
proxies to populate their separate versioned source cache. A Conan hook rejects
a previously unknown source host in proxy mode, so a dependency update cannot
silently bypass Nexus. Generated Debian/Ubuntu build stages rewrite their APT sources to Nexus
when proxy mode is enabled. Once any of these layers contains an artifact, a
build does not fetch it from the public upstream again.

GitHub and GitLab HTTPS clone URLs are rewritten process-locally to the mirror;
the user's global Git configuration is never modified. A repository is cloned
from upstream once. Existing mirrors are always served immediately and ordinary
builds never wait for an upstream refresh. Run `make dependency-cache-refresh`
explicitly to fetch and prune every existing mirror before consuming newly
published commits or tags.

Ordinary dependencies are added through the language's native manifest and
need no proxy configuration. If a package runs its own downloader and bypasses
that registry, add its documented mirror environment variable to the
user-owned `dependency-download-mirrors.env` file. Use
`${DEPENDENCY_GITHUB_RAW_URL}/owner/repository/...` as the URL prefix; the same
entry is expanded to the host or Docker-reachable Nexus address automatically.
Framework-owned defaults are generated from the single `downloadMirrors`
catalog in `servicegen/internal/codegenerator/dependencies.yaml`.

## Changing C++ dependency versions

After changing a pinned C++ dependency version or its acquisition logic, run:

```bash
make dependency-source-cache-invalidate
```

The command removes the project's prepared C++ source cache and its CMake build
volumes. It deliberately preserves compiler `ccache` data and the Nexus proxy.
The next build reconstructs the complete dependency tree; immutable archives
already downloaded by Nexus are reused.