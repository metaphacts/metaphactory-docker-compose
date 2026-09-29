# Knowledge Extractor module

[Knowledge Extractor](#) is a document-annotation service. This module wires it into a service-template-derived instance so it can be deployed alongside metaphactory. Documents uploaded through metaphactory land in a shared docker volume that Knowledge Extractor reads from; vocabularies are handed off to Knowledge Extractor for cartridge conversion via a second shared volume; Knowledge Extractor is reached over the internal docker network only — no host ports are exposed.

## Services

| Service | Image | Purpose |
|---|---|---|
| `knowledge-extractor` | `$KNOWLEDGE_EXTRACTOR_IMAGE` | Document-annotation service |
| `knowledge-extractor-init` | `$METAPHACTORY_IMAGE` | One-shot helper that prepares the shared-volume layout on first `up` (reuses the metaphactory image to keep the external-image footprint small) |

## Ports

All Knowledge Extractor ports are internal-only — reachable from inside the docker compose project as `http://knowledge-extractor:<port>`, not exposed on the host.

| Port | Purpose | Used by |
|---|---|---|
| 9081 | OCP Management (Proc Manager API) | bundled `/bundled/apps/knowledge-extractor` via `ocpProcApiUrl` |
| 9083 | OCM Management | bundled `/bundled/apps/knowledge-extractor` via `ocpMgmtApiUrl` |

## Deploying with Knowledge Extractor

### 1. Create the instance

Follow the standard "Initial Deployment" flow in the [top-level README](../README.md): copy `service-template` to a new folder, copy one of the `database-config` `.env` variants to `.env`, and set a unique `COMPOSE_PROJECT_NAME`. For example, for the GraphDB-bundled variant:

```sh
cp -r service-template my-deployment
cd my-deployment
cp ./database-config/.env_graphdb .env
```

(Use `.env_default`, `.env_rdfox`, or `.env_stardog` instead for another backend.)

### 2. Append the Knowledge Extractor module to `COMPOSE_FILE` in the instance `.env`

Insert `../metaphactory-knowledge-extractor/docker-compose.yml` before `./docker-compose.overwrite.yml`, for example:

```sh
COMPOSE_FILE=./docker-compose.base.yml:../metaphactory/docker-compose.yml:../metaphactory-graphdb/docker-compose.yml:./database-config/docker-compose.graphdb.yml:../metaphactory-knowledge-extractor/docker-compose.yml:./docker-compose.overwrite.yml
```

### 3. Place the Knowledge Extractor license

Knowledge Extractor requires a license file. Place it as `knowledge-extractor.license` in the root of the instance folder you created in step 1 (the `service-template` copy, e.g. `my-deployment/`), alongside your `.env`:

```sh
# in the instance folder
cp /path/to/your-knowledge-extractor.license ./knowledge-extractor.license
```

The module bind-mounts this file (resolved relative to the instance folder) into the Knowledge Extractor container as `/opt/ocm/ocmsvc/data/licenses/ocm.lic`.

### 4. Start

```sh
# in the instance folder
docker compose up -d
```

## How it integrates

- **Networking.** Both metaphactory and Knowledge Extractor attach to `knowledge_extractor_network`. metaphactory addresses Knowledge Extractor as `http://knowledge-extractor:<port>` — the bundled app at `/bundled/apps/knowledge-extractor` (activated via `MP_APP_KNOWLEDGE_EXTRACTOR`) uses these service-name DNS entries directly.
- **External access.** None. Knowledge Extractor exposes no host ports.
- **Shared volumes.** Four named volumes are declared by this module:
  - `document_storage` — mounted at `/opt/ocm/ocmsvc/data/documents` in Knowledge Extractor and `/storage/documents` in metaphactory. The `knowledge-extractor-init` helper creates a `file/` subdirectory plus an `assets -> file` symlink before either service starts.
  - `vocabulary_storage` — the vocabulary hand-off: metaphactory writes the SKOS TTL a vocabulary is converted from to `/storage/vocabularies`; Knowledge Extractor reads it read-only at `/opt/ocm/ocmsvc/data/vocabularies` when running `convertWithVocabulary`.
  - `cartridge_storage` — Knowledge Extractor's own persistent store for converted cartridges, mounted at `/opt/ocm/ocmsvc/data/cartridges`. metaphactory does not mount or write to this volume.
  - `temp_document_storage` — metaphactory-only scratch volume at `/storage/temp-documents`.

## Configurable env vars

The module provides a sensible default for the following — set it in the instance `.env` only if you want to override:

| Var | Default | Purpose |
|---|---|---|
| `KNOWLEDGE_EXTRACTOR_IMAGE` | `metaphacts/knowledge-extractor:6.1.0-2026-09-28` | Docker image used for the `knowledge-extractor` service; override to run a different Knowledge Extractor image |

## Redeploying from scratch

```sh
docker compose down
docker volume rm <project>_document_storage <project>_vocabulary_storage <project>_cartridge_storage <project>_temp_document_storage
docker compose up -d
```

The `knowledge-extractor-init` service repopulates the `file/` + `assets` layout on next `up`.
