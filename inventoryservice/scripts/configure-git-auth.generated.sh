#!/usr/bin/env bash

# Configure credentials only in the ephemeral build container. Tokens are
# passed at runtime and are never copied into the Docker image or source tree.
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  git config --global \
    url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf \
    "https://github.com/"
fi

if [[ -n "${GITLAB_TOKEN:-}" ]]; then
  git config --global \
    url."https://oauth2:${GITLAB_TOKEN}@gitlab.com/".insteadOf \
    "https://gitlab.com/"
fi