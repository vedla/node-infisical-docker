# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-09-23

### Added

- Docker image wrapping the official `node` image with the Infisical CLI, authenticating via
  universal auth and exec'ing the container command with `INFISICAL_TOKEN` set.
- Multi-platform (`linux/amd64`, `linux/arm64`) image builds via `docker buildx`.
- GitLab CI pipeline with SAST and Secret Detection scanning, plus automated image builds and
  publishing on `main`, `master`, `staging`, and `nightly`.
