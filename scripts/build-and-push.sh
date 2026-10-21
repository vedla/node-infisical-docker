#!/bin/sh
# Builds the image for one Node version, smoke-tests it, then pushes it for every platform.
# Used by both .gitlab-ci.yml and .github/workflows/release.yml, so the tagging rules live here.
#
#   scripts/build-and-push.sh <image> <node-version> [release-tag]
#
# Tags pushed, for NODE_VERSION=24-slim:
#   <image>:node-24                  moving tag, rebuilt on every release and scheduled run
#   <image>:node-24-YYYYMMDD         one per build, so a bad rebuild can be rolled back
#   <image>:<release-tag>-node-24    only when a release tag is given; never rebuilt afterwards
set -eu

IMAGE="${1:?usage: build-and-push.sh <image> <node-version> [release-tag]}"
NODE_VERSION="${2:?usage: build-and-push.sh <image> <node-version> [release-tag]}"
RELEASE_TAG="${3:-}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

NODE_TAG="node-${NODE_VERSION%-slim}"
BUILD_DATE="$(date -u +%Y%m%d)"
LOCAL_TAG="node-infisical:smoke-test-${NODE_TAG}"

# --pull fetches the newest base image even if the runner has an older one cached; that is what
# brings in Debian and Node security fixes on scheduled rebuilds.
echo "==> Building ${NODE_TAG} for the smoke test"
docker buildx build --pull --load \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --tag "$LOCAL_TAG" .

# The entrypoint needs Infisical credentials, so test the tools directly. A broken upstream
# release then fails here instead of overwriting a working tag.
echo "==> Smoke-testing ${NODE_TAG}"
docker run --rm --entrypoint node "$LOCAL_TAG" --version
docker run --rm --entrypoint infisical "$LOCAL_TAG" --version
docker run --rm --entrypoint /usr/bin/tini "$LOCAL_TAG" --version
docker run --rm --entrypoint curl "$LOCAL_TAG" --version >/dev/null
docker run --rm --entrypoint sh "$LOCAL_TAG" -c \
  'test "$(stat -c %U /app)" = root && id appuser >/dev/null'

set -- --tag "${IMAGE}:${NODE_TAG}" --tag "${IMAGE}:${NODE_TAG}-${BUILD_DATE}"
if [ -n "$RELEASE_TAG" ]; then
  set -- "$@" --tag "${IMAGE}:${RELEASE_TAG}-${NODE_TAG}"
fi

echo "==> Pushing ${NODE_TAG} for ${PLATFORMS}"
docker buildx build --pull --push \
  --platform "$PLATFORMS" \
  --provenance=false \
  --sbom=false \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  "$@" .
