# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-10-29

### Changed

- Added zsh as default shell.

## [0.1.0] - 2026-10-21

### Added

- Weekly scheduled rebuilds on GitLab (pipeline schedule) and GitHub (`schedule` trigger, plus
  `workflow_dispatch`) that refresh the moving `node-<version>` tags from the latest base image.
- A dated `node-<version>-YYYYMMDD` tag on every build, for rollbacks.
- `scripts/build-and-push.sh`, shared by both pipelines, which smoke-tests each image before
  pushing it.
- An AI policy in `CONTRIBUTING.md`, and merge request and pull request templates that ask for
  the AI disclosure.
- `AGENTS.md` (and a `CLAUDE.md` that includes it) telling coding agents not to write merge
  request descriptions or add AI attribution to them.

### Changed

- GitHub builds now also skip provenance and SBOM attestations, matching GitLab.
- The entrypoint unsets `INFISICAL_CLIENT_ID` and `INFISICAL_CLIENT_SECRET` before starting the
  container command, so the app only receives the short-lived `INFISICAL_TOKEN`.
- `/app` is no longer owned by `appuser`. Images built on this one should copy their files in as
  root and grant write access only to the directories the app writes to.
- tini runs as PID 1, so `SIGTERM` reaches the app and zombie processes are reaped.
- Set `TURBO_TELEMETRY_DISABLED`, `NEXT_TELEMETRY_DISABLED`, and `TELEMETRY_DISABLED`.

## [0.1.0] - 2026-09-23

### Added

- Docker image wrapping the official `node` image with the Infisical CLI, authenticating via
  universal auth and exec'ing the container command with `INFISICAL_TOKEN` set.
- Multi-platform (`linux/amd64`, `linux/arm64`) image builds via `docker buildx`.
- GitLab CI pipeline with SAST and Secret Detection scanning, plus automated image builds and
  publishing on `main`, `master`, `staging`, and `nightly`.
