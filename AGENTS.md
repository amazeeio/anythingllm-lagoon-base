# Repository Workflow

This repository owns the reusable AnythingLLM Lagoon base image and its GHCR publishing flow.

When asked to update AnythingLLM in this repository:

- Treat the Dockerfile ARG `ANYTHINGLLM_VERSION` as the source of truth for the packaged AnythingLLM version.
- Use `scripts/release-anythingllm.sh` instead of manually editing the version when the task is a version bump or release.
- Default to discovering the latest published stable Docker Hub tag automatically unless the user asks for a specific version.
- The expected git tag format is `v<anythingllm-version>`, for example `v1.11.2`.
- The release flow must create a commit that bumps the Dockerfile version, create an annotated git tag with the same version, and push both the branch and the tag when the user asks for a pushed release.
- Do not create ad hoc tag formats, and do not leave the Dockerfile version and git tag out of sync.

Release safety rules:

- Do not force-push.
- Do not create a release commit if the repository has unrelated uncommitted changes.
- Do not create a duplicate tag if `v<version>` already exists.
- After bumping, validate with `docker compose` or Docker-related checks only when relevant to the change.

Preferred commands:

- Dry run or local release preparation: `./scripts/release-anythingllm.sh`
- Pin a specific version: `./scripts/release-anythingllm.sh 1.11.2`
- Commit, tag, and push: `./scripts/release-anythingllm.sh --push`
