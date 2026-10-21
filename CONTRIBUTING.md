# Contributing

Thanks for taking the time to contribute. Contributions are welcome: bug fixes, new Node versions,
documentation, CI improvements, and reports of anything that looks wrong. If you are planning a
larger change, open an issue first so we can agree on the approach.

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

## AI policy

AI-assisted contributions are allowed. You are still the author, so you are responsible for every
line you submit.

- **Disclose it.** In the merge request (or pull request on the GitHub mirror), say which tool you
  used (for example Claude Code, GitHub Copilot, or Cursor), which model (for example Claude Opus
  5.5 or GPT-5), and what you used it for.
- **Review and understand it.** Read every change before you submit it, and be ready to explain
  any part of it. Prompting a tool and submitting what comes back without reviewing it is not a
  contribution.
- **Explain why.** Tell us why the change is needed and why it is done this way, not only what it
  does.
- **Write the description yourself.** The title and description must be written by a person, not
  generated. Code, tests, and commit messages can be AI-assisted; the description is where you
  show that you understand the change.

Requests that skip the disclosure, or whose author cannot explain the change, may be closed. The
merge request and pull request templates have a section for this.

## Reporting issues

Open an issue with steps to reproduce, the `NODE_VERSION` build arg used, and relevant logs
(with any secrets redacted).
