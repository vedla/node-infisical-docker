# Node Infisical Docker Image

[![pipeline status](https://gitlab.com/vedla/node-infisical-docker/badges/main/pipeline.svg)](https://gitlab.com/vedla/node-infisical-docker/-/commits/main)
[![coverage report](https://gitlab.com/vedla/node-infisical-docker/badges/main/coverage.svg)](https://gitlab.com/vedla/node-infisical-docker/-/commits/main)
[![Latest Release](https://gitlab.com/vedla/node-infisical-docker/-/badges/release.svg)](https://gitlab.com/vedla/node-infisical-docker/-/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A multi-platform Docker image that wraps the official [`node`](https://hub.docker.com/_/node)
image with the [Infisical CLI](https://infisical.com/docs/cli/overview), so a container can
authenticate to Infisical via [universal auth](https://infisical.com/docs/documentation/platform/identities/universal-auth)
and run your Node.js process with a valid `INFISICAL_TOKEN` already exported — no secrets baked
into the image or passed around as plaintext build args.

## How it works

The entrypoint ([`entrypoint.sh`](entrypoint.sh)) runs before your command:

1. Validates that `INFISICAL_DOMAIN`, `INFISICAL_CLIENT_ID`, and `INFISICAL_CLIENT_SECRET` are set.
2. Logs in to Infisical using universal auth and captures a short-lived token.
3. Exports the token as `INFISICAL_TOKEN`.
4. `exec`s the container's command (e.g. `node server.js`, `npm start`), so your app can use the
   [Infisical Node SDK](https://infisical.com/docs/sdks/languages/node) or the `infisical run`
   wrapper to fetch secrets at runtime.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with [Buildx](https://docs.docker.com/buildx/working-with-buildx/)
  for multi-platform builds.
- An Infisical [machine identity](https://infisical.com/docs/documentation/platform/identities/universal-auth)
  configured for universal auth, giving you a client ID and client secret.

## Building the image

Build and publish one multi-platform image for AMD64 and ARM64. Set `NODE_VERSION` once so it
controls both the Node base image and the tag:

```sh
NODE_VERSION=24.13.0-slim
IMAGE=ghcr.io/vedla/node-infisical

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --tag "$IMAGE:node-${NODE_VERSION%-slim}" \
  --push .
```

The example publishes the tag `node-24.13.0`. `--push` publishes one tag containing both platform
variants. Use `--load` instead only for a single local platform.

### Build arguments

| Argument       | Default             | Description                                   |
| -------------- | -------------------- | ---------------------------------------------- |
| `NODE_VERSION` | `24.13.0-slim`        | Tag of the [`node`](https://hub.docker.com/_/node) base image to build from. |

## Running the image

Run the image by providing `INFISICAL_DOMAIN`, `INFISICAL_CLIENT_ID`, and
`INFISICAL_CLIENT_SECRET`:

```sh
docker run --rm \
  -e INFISICAL_DOMAIN \
  -e INFISICAL_CLIENT_ID \
  -e INFISICAL_CLIENT_SECRET \
  "$IMAGE:node-24.13.0" node --version
```

### Environment variables

| Variable                   | Required | Description                                                        |
| --------------------------- | -------- | -------------------------------------------------------------------- |
| `INFISICAL_DOMAIN`          | Yes      | Base URL of your Infisical instance (e.g. `https://app.infisical.com`). |
| `INFISICAL_CLIENT_ID`       | Yes      | Universal auth client ID for the machine identity.                    |
| `INFISICAL_CLIENT_SECRET`   | Yes      | Universal auth client secret for the machine identity.                |
| `INFISICAL_TOKEN`           | Set by entrypoint | Short-lived access token exported for your process to consume. Do not set this yourself. |

Pass credentials via your orchestrator's secret store (e.g. Docker/Swarm secrets, Kubernetes
secrets, CI/CD masked variables) rather than plaintext environment files.

## Extending this image

Use it as a base image and let the inherited `ENTRYPOINT` handle Infisical auth for you — just
add your app and set `CMD` (or pass a command at `docker run` time), don't override `ENTRYPOINT`:

```dockerfile
FROM ghcr.io/vedla/node-infisical-docker:node-24.13.0

# WORKDIR /app and the entrypoint are inherited; just add your app on top.
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# Optional: drop root and run as the non-root user the base image already created.
USER appuser

CMD ["node", "server.js"]
```

Build and run it the same way as any other image; the base image's `ENTRYPOINT` still runs first,
authenticates with Infisical, and then `exec`s your `CMD`:

```sh
docker build -t my-app .
docker run --rm \
  -e INFISICAL_DOMAIN \
  -e INFISICAL_CLIENT_ID \
  -e INFISICAL_CLIENT_SECRET \
  -p 3000:3000 \
  my-app
```

Notes for sub-images:

- `WORKDIR /app` and `appuser`/`nodejs` (uid/gid `1001`) are already set up by the base image; add
  `USER appuser` yourself if you want to run as that user instead of root.
- `NODE_VERSION` is baked into the tag you `FROM` — pin to a specific `node-<version>` tag rather
  than relying on a mutable one, so your build doesn't shift under you.
- If you need Infisical to inject secrets as files or additional env vars (not just
  `INFISICAL_TOKEN`), wrap your `CMD` with [`infisical run --`](https://infisical.com/docs/cli/commands/run)
  instead of calling your process directly.

## CI/CD

[`.gitlab-ci.yml`](.gitlab-ci.yml) runs on every pipeline:

- **SAST** and **Secret Detection** ([GitLab templates](https://docs.gitlab.com/user/application_security/))
  scan the repository for vulnerabilities and committed secrets.
- **`build-check`** runs `docker build` (single-platform, no push) on every branch push to catch a
  broken `Dockerfile` before release. It also drives the coverage badge above — there's no test
  suite here, so it reports 100% when the build succeeds and 0% when it fails.

Images are only built and published **when a release tag is pushed** (i.e. `$CI_COMMIT_TAG` is
set), not on every commit to `main`:

- **`build-images`** runs once per Node version listed in its `parallel: matrix` (currently the
  Maintenance LTS, Active LTS, and Current lines) and pushes a multi-platform image to
  `$CI_REGISTRY_IMAGE`, tagged as `node-<version>` and `<tag>-node-<version>`.
- **`release`** runs after all matrix builds succeed and creates the corresponding
  [GitLab Release](https://gitlab.com/vedla/node-infisical-docker/-/releases) for the tag.

To cut a release: update the `NODE_VERSION` matrix in `.gitlab-ci.yml` if the set of versions to
build needs to change, then push a tag (e.g. `git tag v1.2.0 && git push origin v1.2.0`).

GitLab automatically mirrors pushes (including tags) to the [GitHub mirror](https://gitlab.com/vedla/node-infisical-docker).
[`.github/workflows/release.yml`](.github/workflows/release.yml) picks up that tag and runs the
equivalent flow there: builds the same `NODE_VERSION` matrix, pushes multi-platform images to
`ghcr.io/vedla/node-infisical-docker`, and creates the matching GitHub Release. **Keep the `NODE_VERSION`
matrix in both files in sync** — there's no shared source between them.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose changes and test them locally.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

[MIT](LICENSE)

## Repository Information

GitHub is used for public releases, discussions, and community contributions.

Development infrastructure, CI/CD, and internal tooling are managed through [GitLab](https://gitlab.com/vedla/node-infisical-docker)

