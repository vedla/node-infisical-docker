# Agent Instructions

## Merge Requests and Commits

Contributors may use AI tools, under the AI policy in `CONTRIBUTING.md`. Agents working here must
follow it too:

- **NEVER** write a merge request (or pull request) title or description, and never add a
  "Generated with" line, robot emoji, or other AI attribution to one. The description must be
  written by the person submitting the change. If you are asked to open one, give the person the
  facts they need in chat (what changed, why, how it was tested) and let them write it.
- Commit messages may be written by you. A `Co-Authored-By` trailer naming the tool is fine, but it
  does not replace the disclosure in the merge request.
- When you finish a change, remind the person that the merge request must state the tool, the
  model, and what it was used for, and that they must review and understand every change first.

## Working in this repository

- Keep the `NODE_VERSION` matrix in `.gitlab-ci.yml` and `.github/workflows/release.yml` in sync.
- Both pipelines build through `scripts/build-and-push.sh`; change tagging or smoke tests there.
- `/app` stays owned by root and the entrypoint unsets the Infisical client credentials before
  `exec`; do not undo either.
- Update `README.md` and `CHANGELOG.md` when a change affects usage, tags, build args, or
  environment variables.
