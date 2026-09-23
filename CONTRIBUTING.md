# Contributing

Thanks for taking the time to contribute.

## Getting started

1. Fork or branch off `main`.
2. Make your changes to the `Dockerfile`, `entrypoint.sh`, or CI configuration.
3. Build the image locally for your platform before opening a merge request:

   ```sh
   docker buildx build --load --build-arg NODE_VERSION=24.13.0-slim -t node-infisical:dev .
   ```

4. Smoke-test the entrypoint:

   ```sh
   docker run --rm \
     -e INFISICAL_DOMAIN \
     -e INFISICAL_CLIENT_ID \
     -e INFISICAL_CLIENT_SECRET \
     node-infisical:dev node --version
   ```

## Submitting changes

- Open a merge request against `main` with a clear description of the change and why it's needed.
- Keep changes focused; avoid unrelated formatting or refactors in the same MR.
- CI runs SAST and Secret Detection on every pipeline — make sure your MR passes both before
  requesting review. Never commit real Infisical credentials, tokens, or `.env` files.
- Update `README.md` and `CHANGELOG.md` when your change affects usage, build args, or required
  environment variables.

## Reporting issues

Open an issue with steps to reproduce, the `NODE_VERSION` build arg used, and relevant logs
(with any secrets redacted).
