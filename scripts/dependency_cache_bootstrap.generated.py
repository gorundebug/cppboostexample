#!/usr/bin/env python3
"""Idempotently configure the generated local Nexus dependency proxy."""

from __future__ import annotations

import argparse
import base64
import json
import os
from pathlib import Path
import secrets
import sys
import urllib.error
import urllib.request


def request(
    url: str,
    password: str,
    method: str,
    path: str,
    body=None,
    content_type: str = "application/json",
):
    data = None if body is None else json.dumps(body).encode()
    headers = {"Accept": "application/json"}
    if data is not None:
        if content_type == "text/plain":
            data = str(body).encode()
        headers["Content-Type"] = content_type
    token = base64.b64encode(f"admin:{password}".encode()).decode()
    headers["Authorization"] = f"Basic {token}"
    req = urllib.request.Request(url + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            payload = response.read()
            return None if not payload else json.loads(payload)
    except urllib.error.HTTPError as error:
        detail = error.read().decode(errors="replace")
        raise RuntimeError(f"{method} {path}: HTTP {error.code}: {detail}") from error


def common(name: str, remote_url: str) -> dict:
    return {
        "name": name,
        "online": True,
        "storage": {"blobStoreName": "default", "strictContentTypeValidation": True},
        "proxy": {
            "remoteUrl": remote_url,
            "contentMaxAge": 1440,
            "metadataMaxAge": 60,
            "preserveEncodedCharacters": False,
        },
        "negativeCache": {"enabled": True, "timeToLive": 60},
        "httpClient": {
            "blocked": False,
            "autoBlock": True,
            "connection": {
                "retries": 2,
                "userAgentSuffix": "servicegen-local-dependency-cache",
                "timeout": 60,
                "enableCircularRedirects": False,
                "enableCookies": False,
                "useTrustStore": False,
            },
        },
    }


def repositories() -> list[tuple[str, str, str, dict]]:
    maven = common("maven-central", "https://repo1.maven.org/maven2")
    maven["raw"] = {
        "contentDisposition": "ATTACHMENT",
        "forwardQueryParameters": True,
        "excludedQueryParameters": [],
    }
    github = common("github-raw", "https://github.com")
    github["proxy"]["contentMaxAge"] = -1
    github["proxy"]["metadataMaxAge"] = -1
    github["raw"] = {
        "contentDisposition": "ATTACHMENT",
        "forwardQueryParameters": True,
        "excludedQueryParameters": [],
    }
    gitlab = common("gitlab-raw", "https://gitlab.com")
    gitlab["proxy"]["contentMaxAge"] = -1
    gitlab["proxy"]["metadataMaxAge"] = -1
    gitlab["raw"] = {
        "contentDisposition": "ATTACHMENT",
        "forwardQueryParameters": True,
        "excludedQueryParameters": [],
    }
    definitions = [
        ("go", "proxy", "go-proxy", common("go-proxy", "https://proxy.golang.org")),
        ("npm", "proxy", "npm-proxy", common("npm-proxy", "https://registry.npmjs.org")),
        ("pypi", "proxy", "pypi-proxy", common("pypi-proxy", "https://pypi.org")),
        ("cargo", "proxy", "cargo-proxy", common("cargo-proxy", "https://index.crates.io")),
        ("helm", "proxy", "helm-prometheus", common("helm-prometheus", "https://prometheus-community.github.io/helm-charts")),
        ("helm", "proxy", "helm-grafana", common("helm-grafana", "https://grafana.github.io/helm-charts")),
        ("helm", "proxy", "helm-opentelemetry", common("helm-opentelemetry", "https://open-telemetry.github.io/opentelemetry-helm-charts")),
        ("helm", "proxy", "helm-jaeger", common("helm-jaeger", "https://jaegertracing.github.io/helm-charts")),
        ("helm", "proxy", "helm-redpanda", common("helm-redpanda", "https://charts.redpanda.com")),
        ("raw", "proxy", "maven-central", maven),
        ("raw", "proxy", "github-raw", github),
        ("raw", "proxy", "gitlab-raw", gitlab),
    ]
    for name, remote_url in (
        ("conan-source-archives-boost", "https://archives.boost.io"),
        ("conan-source-cmake", "https://cmake.org"),
        ("conan-source-curl", "https://curl.se"),
        ("conan-source-schmorp", "http://dist.schmorp.de"),
        ("conan-source-ariadne", "https://distfiles.ariadne.space"),
        ("conan-source-gnu-ftp", "https://ftp.gnu.org"),
        ("conan-source-gnu-mirror", "https://ftpmirror.gnu.org"),
        ("github-raw", "https://github.com"),
        ("conan-source-savannah-git", "https://https.git.savannah.gnu.org"),
        ("conan-source-kernel", "https://mirrors.kernel.org"),
        ("conan-source-sourceforge", "https://sourceforge.net"),
        ("conan-source-sourceware", "https://sourceware.org"),
        ("conan-source-mirrorservice", "https://www.mirrorservice.org"),
        ("conan-source-zlib", "https://zlib.net"),
    ):
        if name in {"github-raw"}:
            continue
        raw_source = common(name, remote_url)
        raw_source["proxy"]["contentMaxAge"] = -1
        raw_source["proxy"]["metadataMaxAge"] = -1
        raw_source["raw"] = {
            "contentDisposition": "ATTACHMENT",
            "forwardQueryParameters": True,
            "excludedQueryParameters": [],
        }
        definitions.append(("raw", "proxy", name, raw_source))
    conan = common("conan-proxy", "https://center2.conan.io")
    conan["conanProxy"] = {"conanVersion": "V2"}
    definitions.append(("conan", "proxy", "conan-proxy", conan))
    definitions.append((
        "conan",
        "hosted",
        "conan-hosted",
        {
            "name": "conan-hosted",
            "online": True,
            "storage": {
                "blobStoreName": "default",
                "strictContentTypeValidation": True,
                "writePolicy": "ALLOW",
            },
        },
    ))
    definitions.append((
        "conan",
        "group",
        "conan-group",
        {
            "name": "conan-group",
            "online": True,
            "storage": {
                "blobStoreName": "default",
                "strictContentTypeValidation": True,
            },
            "group": {"memberNames": ["conan-hosted", "conan-proxy"]},
        },
    ))
    definitions[2][3]["pypi"] = {"indexPath": "/simple"}
    definitions[3][3]["cargo"] = {"requireAuthentication": False}
    docker = common("docker-hub", "https://registry-1.docker.io")
    docker["docker"] = {
        "v1Enabled": False,
        "forceBasicAuth": False,
        "httpPort": 8082,
        "pathEnabled": False,
    }
    docker["dockerProxy"] = {
        "indexType": "HUB",
        "cacheForeignLayers": True,
        "foreignLayerUrlWhitelist": [],
    }
    definitions.append(("docker", "proxy", "docker-hub", docker))
    for name, remote_url in (
        ("apt-ubuntu-archive", "http://archive.ubuntu.com/ubuntu/"),
        ("apt-ubuntu-security", "http://security.ubuntu.com/ubuntu/"),
        ("apt-ubuntu-ports", "http://ports.ubuntu.com/ubuntu-ports/"),
        ("apt-debian", "http://deb.debian.org/debian/"),
        ("apt-debian-security", "http://deb.debian.org/debian-security/"),
    ):
        apt = common(name, remote_url)
        apt["apt"] = {"distribution": "", "flat": False}
        definitions.append(("apt", "proxy", name, apt))
    return definitions


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--password")
    parser.add_argument("--conan-password")
    parser.add_argument("--conan-credential-file")
    parser.add_argument(
        "--accept-eula",
        action="store_true",
        default=os.environ.get("DEPENDENCY_PROXY_ACCEPT_EULA", "").lower()
        in {"1", "true", "yes"},
    )
    args = parser.parse_args()
    base_url = args.url.rstrip("/")
    password = args.password or os.environ.get("DEPENDENCY_PROXY_ADMIN_PASSWORD", "")
    if not password:
        raise RuntimeError("Nexus administrator password is not configured")

    conan_password = args.conan_password
    if args.conan_credential_file:
        credential_file = Path(args.conan_credential_file)
        if credential_file.exists():
            credential = credential_file.read_text().splitlines()
            if len(credential) < 2 or credential[0] != "dependency-cache-conan":
                raise RuntimeError(
                    f"invalid Conan publisher credential file: {credential_file}"
                )
            conan_password = credential[1]
        else:
            conan_password = secrets.token_urlsafe(32)
            credential_file.parent.mkdir(parents=True, exist_ok=True)
            credential_file.write_text(
                f"dependency-cache-conan\n{conan_password}\n"
            )
            credential_file.chmod(0o600)
    if not conan_password:
        raise RuntimeError("Conan publisher password is not configured")

    eula = request(
        base_url, password, "GET", "/service/rest/v1/system/eula"
    )
    if not eula.get("accepted", False):
        if not args.accept_eula:
            raise RuntimeError(
                "Nexus Community Edition EULA is not accepted; read "
                "https://links.sonatype.com/products/nxrm/ce-eula and set "
                "DEPENDENCY_PROXY_ACCEPT_EULA=true to accept it"
            )
        request(
            base_url,
            password,
            "POST",
            "/service/rest/v1/system/eula",
            {"accepted": True, "disclaimer": eula.get("disclaimer", "")},
        )
        print("[dependency-cache] Nexus Community Edition EULA accepted")

    existing = {
        item["name"] for item in request(
            base_url, password, "GET", "/service/rest/v1/repositories"
        )
    }
    for format_name, repository_type, name, payload in repositories():
        if name in existing:
            request(
                base_url,
                password,
                "PUT",
                f"/service/rest/v1/repositories/{format_name}/{repository_type}/{name}",
                payload,
            )
            print(f"[dependency-cache] updated {name}")
            continue
        request(
            base_url,
            password,
            "POST",
            f"/service/rest/v1/repositories/{format_name}/{repository_type}",
            payload,
        )
        print(f"[dependency-cache] created {name}")

    privilege_name = "dependency-cache-conan-upload"
    privilege = {
        "name": privilege_name,
        "description": "Upload locally built Conan binary packages",
        "actions": ["BROWSE", "READ", "ADD", "EDIT"],
        "format": "conan",
        "repository": "conan-hosted",
    }
    privileges = {
        item["name"] for item in request(
            base_url, password, "GET", "/service/rest/v1/security/privileges"
        )
    }
    if privilege_name in privileges:
        request(
            base_url,
            password,
            "PUT",
            f"/service/rest/v1/security/privileges/repository-view/{privilege_name}",
            privilege,
        )
    else:
        request(
            base_url,
            password,
            "POST",
            "/service/rest/v1/security/privileges/repository-view",
            privilege,
        )

    role_id = "dependency-cache-conan-publisher"
    role = {
        "id": role_id,
        "name": "Dependency cache Conan publisher",
        "description": "Publishes locally built Conan binary packages",
        "privileges": [privilege_name],
        "roles": [],
    }
    roles = {
        item["id"] for item in request(
            base_url, password, "GET", "/service/rest/v1/security/roles"
        )
    }
    request(
        base_url,
        password,
        "PUT" if role_id in roles else "POST",
        f"/service/rest/v1/security/roles/{role_id}" if role_id in roles
        else "/service/rest/v1/security/roles",
        role,
    )

    user_id = "dependency-cache-conan"
    users = {
        item["userId"] for item in request(
            base_url, password, "GET", "/service/rest/v1/security/users"
        )
    }
    if user_id not in users:
        request(
            base_url,
            password,
            "POST",
            "/service/rest/v1/security/users",
            {
                "userId": user_id,
                "firstName": "Dependency cache",
                "lastName": "Conan publisher",
                "emailAddress": "dependency-cache@localhost",
                "password": conan_password,
                "status": "active",
                "roles": [role_id],
            },
        )
    else:
        request(
            base_url,
            password,
            "PUT",
            f"/service/rest/v1/security/users/{user_id}",
            {
                "userId": user_id,
                "firstName": "Dependency cache",
                "lastName": "Conan publisher",
                "emailAddress": "dependency-cache@localhost",
                "source": "default",
                "status": "active",
                "roles": [role_id],
            },
        )
        request(
            base_url,
            password,
            "PUT",
            f"/service/rest/v1/security/users/{user_id}/change-password",
            conan_password,
            "text/plain",
        )
    print("[dependency-cache] Conan hosted/group and publisher configured")

    request(
        base_url,
        password,
        "PUT",
        "/service/rest/v1/security/anonymous",
        {"enabled": True, "userId": "anonymous", "realmName": "NexusAuthorizingRealm"},
    )
    print("[dependency-cache] anonymous read access enabled")

    realms = request(
        base_url, password, "GET", "/service/rest/v1/security/realms/active"
    )
    required_realms = [realm for realm in ("DockerToken", "ConanToken") if realm not in realms]
    if required_realms:
        request(
            base_url,
            password,
            "PUT",
            "/service/rest/v1/security/realms/active",
            [*realms, *required_realms],
        )
        print(
            "[dependency-cache] enabled bearer token realms: "
            + ", ".join(required_realms)
        )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"[dependency-cache] ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)