# anythingllm-lagoon-base

This repository owns the reusable AnythingLLM runtime image for Lagoon deployments. It builds the base container once and publishes it to GHCR so downstream Lagoon projects can pull the image instead of rebuilding the same runtime on every deployment.

## Published image

The image is published to:

- `ghcr.io/amazeeio/anythingllm-lagoon-base:latest`
- `ghcr.io/amazeeio/anythingllm-lagoon-base:main`
- `ghcr.io/amazeeio/anythingllm-lagoon-base:<git-tag>` for version tags such as `v1.11.2`

`latest` is the floating consumer tag. `main` is the integration tag. Version tags are the rollback-safe option.

## What lives here

This repo is the source of truth for:

- The AnythingLLM base image version pin
- Lagoon-compatible permissions for arbitrary runtime UIDs
- Build-time Prisma client generation
- The custom entrypoint that skips runtime `prisma generate`
- Shared runtime directories and defaults used by downstream Lagoon repos

Downstream repos should not duplicate these files.

## Publish flow

A GitHub Actions workflow at `.github/workflows/publish.yml` builds and publishes the image to GHCR on every push to `main`, and also on version tags matching `v*`.

The workflow uses the repository `GITHUB_TOKEN` to publish to GHCR. After the first publish, set the package visibility to public in GitHub Packages if it is not already public.

## Updating AnythingLLM

This repository includes a helper script for bumping the packaged AnythingLLM version and creating the matching git tag that drives tagged image builds.

```bash
./scripts/release-anythingllm.sh
```

That command resolves the latest stable published `mintplexlabs/anythingllm` Docker Hub tag, updates `ARG ANYTHINGLLM_VERSION` in `Dockerfile`, creates a commit, and creates an annotated tag in the format `v<version>`.

To pin a specific version:

```bash
./scripts/release-anythingllm.sh 1.11.2
```

To also push the branch and tag to `origin`:

```bash
./scripts/release-anythingllm.sh --push
```

## Automatic AnythingLLM releases

This repository can also release itself automatically when a newer stable AnythingLLM image tag is published. The scheduled workflow at `.github/workflows/release-anythingllm.yml` runs four times per day and also supports manual dispatch.

When it detects a newer AnythingLLM version, it runs the same release helper, commits the Dockerfile bump, creates the matching annotated git tag, pushes both, and publishes the GHCR image in the same workflow run.

No extra repository secret is required for the scheduled release flow. It uses the repository `GITHUB_TOKEN` to push the release commit and tag, and to publish the image directly. This avoids relying on a second workflow trigger from the automation-created push.

Repository-local agent guidance for this workflow is stored in `AGENTS.md`.

## Consumer usage

A downstream Lagoon repo can reference the published image directly in `docker-compose.yml`:

```yaml
services:
  anythingllm:
    platform: linux/amd64
    image: ghcr.io/amazeeio/anythingllm-lagoon-base:latest
    user: "10000"
    ports:
      - "3000:3000"
    environment:
      STORAGE_DIR: /app/server/storage
      SERVER_PORT: "3000"
      EMBEDDING_PROVIDER: ${EMBEDDING_PROVIDER:-native}
      DISABLE_TELEMETRY: "true"
      LLM_PROVIDER: generic-openai
      OPEN_AI_KEY: ${LLM_AI_KEY:-}
      OPEN_AI_BASE_PATH: ${LLM_URL:-}
      JWT_SECRET: ${JWT_SECRET:-}
```

If the downstream change is reusable across deployments, make it here instead.

## Local build

For local verification of the base image itself:

```bash
docker build -t anythingllm-lagoon-base:dev .
docker run --rm -p 3000:3000 anythingllm-lagoon-base:dev
```

## Runtime environment

The image expects the same environment variables currently used by AnythingLLM Lagoon deployments, including:

- `JWT_SECRET`
- `LLM_URL`
- `LLM_AI_KEY`
- `EMBEDDING_PROVIDER`
- `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME`, and `DB_PORT` when external Postgres is used

Runtime state is stored under `/app/server/storage`.
