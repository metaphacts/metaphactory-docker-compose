# Deep module

[Deep](#) is a document-annotation service. This module wires it into a service-template-derived instance so it can be deployed alongside metaphactory. Documents uploaded through metaphactory land in a shared docker volume that Deep reads from; Deep is reached over the internal docker network only — no host ports are exposed.

## Services

| Service | Image | Purpose |
|---|---|---|
| `deep` | `$DEEP_IMAGE` | Document-annotation service |
| `deep-init` | `$METAPHACTORY_IMAGE` | One-shot helper that prepares the shared-volume layout on first `up` (reuses the metaphactory image to keep the external-image footprint small) |

## Ports

All Deep ports are internal-only — reachable from inside the docker compose project as `http://deep:<port>`, not exposed on the host.

| Port | Purpose | Used by |
|---|---|---|
| 9081 | OCP Management (Proc Manager API) | bundled `/bundled/apps/deep` via `ocpProcApiUrl` |
| 9083 | OCM Management | bundled `/bundled/apps/deep` via `ocpMgmtApiUrl` |

## Deploying with Deep

### 1. Create the instance

Follow the standard "Initial Deployment" flow in the [top-level README](../README.md): copy `service-template` to a new folder, copy one of the `database-config` `.env` variants to `.env`, and set a unique `COMPOSE_PROJECT_NAME`. For example, for the GraphDB-bundled variant:

```sh
cp -r service-template my-deployment
cd my-deployment
cp ./database-config/.env_graphdb .env
```

(Use `.env_default`, `.env_rdfox`, or `.env_stardog` instead for another backend.)

### 2. Append the Deep module to `COMPOSE_FILE` in the instance `.env`

Insert `../metaphactory-deep/docker-compose.yml` before `./docker-compose.overwrite.yml`, for example:

```sh
COMPOSE_FILE=./docker-compose.base.yml:../metaphactory/docker-compose.yml:../metaphactory-graphdb/docker-compose.yml:./database-config/docker-compose.graphdb.yml:../metaphactory-deep/docker-compose.yml:./docker-compose.overwrite.yml
```

### 3. Place the Deep license

Deep requires a license file. Place it as `deep.license` in the root of the instance folder you created in step 1 (the `service-template` copy, e.g. `my-deployment/`), alongside your `.env`:

```sh
# in the instance folder
cp /path/to/your-deep.license ./deep.license
```

The module bind-mounts this file (resolved relative to the instance folder) into the Deep container as `/opt/ocm/ocmsvc/data/licenses/ocm.lic`.

### 4. Adjust the Content Security Policy (required)

Deep's digital-document page renders uploaded PDFs inline, which requires
metaphactory to serve them via `blob:` URLs. The default metaphactory CSP does
not permit this, so the policy must be widened in the deployment. Add the
following to the `metaphactory` service in your instance's
`docker-compose.overwrite.yml`:

```yaml
services:
  metaphactory:
    environment:
      - "CONTENT_SECURITY_POLICY=default-src 'self'; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; object-src 'self'; img-src 'self' https: data: blob:; font-src 'self' data:;"
      - "X_FRAME_OPTIONS=SAMEORIGIN"
```

Without this override, PDF documents will not display on the Deep document page.

### 5. Start

```sh
# in the instance folder
docker compose up -d
```

## How it integrates

- **Networking.** Both metaphactory and Deep attach to `deep_network`. metaphactory addresses Deep as `http://deep:<port>` — the bundled app at `/bundled/apps/deep` (activated via `MP_APP_DEEP`) uses these service-name DNS entries directly.
- **External access.** None. Deep exposes no host ports.
- **Shared volumes.** Two named volumes are declared by this module:
  - `document_storage` — mounted at `/opt/ocm/ocmsvc/data/sources` in Deep and `/storage/documents` in metaphactory. The `deep-init` helper creates a `file/` subdirectory plus an `assets -> file` symlink before either service starts.
  - `temp_document_storage` — metaphactory-only scratch volume at `/storage/temp-documents`.

## Configurable env vars

The module provides a sensible default for the following — set it in the instance `.env` only if you want to override:

| Var | Default | Purpose |
|---|---|---|
| `DEEP_IMAGE` | `metaphacts/deep:2026-07-07` | Docker image used for the `deep` service; override to run a different Deep image |

## Redeploying from scratch

```sh
docker compose down
docker volume rm <project>_document_storage <project>_temp_document_storage
docker compose up -d
```

The `deep-init` service repopulates the `file/` + `assets` layout on next `up`.
