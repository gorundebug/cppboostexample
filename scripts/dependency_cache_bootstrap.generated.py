#!/usr/bin/env python3
"""Idempotently configure the generated local Nexus dependency proxy."""

from __future__ import annotations

import argparse
import base64
import json
import sys
import urllib.error
import urllib.request


def request(url: str, password: str, method: str, path: str, body=None):
    data = None if body is None else json.dumps(body).encode()
    headers = {"Accept": "application/json"}
    if data is not None:
        headers["Content-Type"] = "application/json"
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


def repositories() -> list[tuple[str, str, dict]]:
    definitions = [
        ("go", "go-proxy", common("go-proxy", "https://proxy.golang.org")),
        ("npm", "npm-proxy", common("npm-proxy", "https://registry.npmjs.org")),
        ("pypi", "pypi-proxy", common("pypi-proxy", "https://pypi.org")),
        ("cargo", "cargo-proxy", common("cargo-proxy", "https://index.crates.io")),
        ("helm", "helm-prometheus", common("helm-prometheus", "https://prometheus-community.github.io/helm-charts")),
        ("helm", "helm-grafana", common("helm-grafana", "https://grafana.github.io/helm-charts")),
        ("helm", "helm-opentelemetry", common("helm-opentelemetry", "https://open-telemetry.github.io/opentelemetry-helm-charts")),
        ("helm", "helm-jaeger", common("helm-jaeger", "https://jaegertracing.github.io/helm-charts")),
        ("helm", "helm-redpanda", common("helm-redpanda", "https://charts.redpanda.com")),
        ("raw", "maven-central", common("maven-central", "https://repo1.maven.org/maven2")),
    ]
    definitions[2][2]["pypi"] = {"indexPath": "/simple"}
    definitions[3][2]["cargo"] = {"requireAuthentication": False}
    definitions[9][2]["raw"] = {
        "contentDisposition": "ATTACHMENT",
        "forwardQueryParameters": True,
        "excludedQueryParameters": [],
    }
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
    definitions.append(("docker", "docker-hub", docker))
    return definitions


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--accept-eula", action="store_true")
    args = parser.parse_args()
    base_url = args.url.rstrip("/")

    eula = request(
        base_url, args.password, "GET", "/service/rest/v1/system/eula"
    )
    if not eula.get("accepted", False):
        if not args.accept_eula:
            raise RuntimeError(
                "Nexus Community Edition EULA is not accepted; read "
                "https://links.sonatype.com/products/nxrm/ce-eula and set "
                "SERVICEGEN_NEXUS_ACCEPT_EULA=true to accept it"
            )
        request(
            base_url,
            args.password,
            "POST",
            "/service/rest/v1/system/eula",
            {"accepted": True, "disclaimer": eula.get("disclaimer", "")},
        )
        print("[dependency-cache] Nexus Community Edition EULA accepted")

    existing = {
        item["name"] for item in request(
            base_url, args.password, "GET", "/service/rest/v1/repositories"
        )
    }
    for format_name, name, payload in repositories():
        if name in existing:
            print(f"[dependency-cache] reuse {name}")
            continue
        request(
            base_url,
            args.password,
            "POST",
            f"/service/rest/v1/repositories/{format_name}/proxy",
            payload,
        )
        print(f"[dependency-cache] created {name}")

    request(
        base_url,
        args.password,
        "PUT",
        "/service/rest/v1/security/anonymous",
        {"enabled": True, "userId": "anonymous", "realmName": "NexusAuthorizingRealm"},
    )
    print("[dependency-cache] anonymous read access enabled")

    realms = request(
        base_url, args.password, "GET", "/service/rest/v1/security/realms/active"
    )
    if "DockerToken" not in realms:
        request(
            base_url,
            args.password,
            "PUT",
            "/service/rest/v1/security/realms/active",
            [*realms, "DockerToken"],
        )
        print("[dependency-cache] Docker bearer token realm enabled")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"[dependency-cache] ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)