# Ontopic module

The mapping and virtualization capabilities of the Semantic Layer are powered by Ontopic, deployed alongside metaphactory. Ontopic provides the environment for AI-assisted creation, curation and review of the executable (R2RML) mappings, and serves these mappings as SPARQL endpoints over your relational databases—making the data queryable as a knowledge graph without physically moving it. 

## Services

The Ontopic module provides the following services:

| Service | Image | Purpose |
|---|---|---|
| `angular-frontend` | `metaphacts/ontopic:studio-<version>` | Ontopic Studio web UI |
| `process-server` | `metaphacts/ontopic:process-server-<version>` | Query processing backend |
| `store-server` | `metaphacts/ontopic:store-server-<version>` | Project/policy store backend |
| `store-server-db` | `postgres:18.4` | PostgreSQL for `store-server` (community image; pinned to 18.4) |
| `ontopic-server` | `metaphacts/ontopic:ontopic-server-<version>` | Semantic SQL / SPARQL endpoint server |
| `ai-server` | `metaphacts/ontopic:ai-server-<version>` | LLM-backed AI assistant for Ontopic Studio (requires an OpenAI/Anthropic key — see step 5) |

All Ontopic-suite images live in a single Docker Hub repository, tagged `<function>-<version>`. Both the repository and the version can be overridden from the instance `.env`:

- `ONTOPIC_REPOSITORY` — default `metaphacts/ontopic`.
- `ONTOPIC_VERSION` — default `6.0.0`.

## Using this module in an instance

The module is activated from any instance folder derived from `service-template` (e.g. `my-deployment/`).

### 1. Create the instance

Follow the standard "Initial Deployment" flow in the [top-level README](../README.md): copy `service-template` to a new folder and copy one of the database-config `.env` variants to `.env`. For example, for the default (external database) setup:

```sh
cp -r service-template my-deployment
cd my-deployment
cp database-config/.env_default .env
```

(Use `.env_graphdb`, `.env_rdfox`, or `.env_stardog` instead to bundle the respective database.)

### 2. Activate the Ontopic module in the instance `.env`

Add the module's compose file to the `COMPOSE_FILE` variable in your instance `.env` (the paths are `:`-separated). Insert it **near the end, but before the final `./docker-compose.overwrite.yml`** — that file is the instance's own customization layer and must stay last so your customizations always win (in `COMPOSE_FILE`, later files override earlier ones). For example, starting from the `.env_default` value:

```sh
COMPOSE_FILE=./docker-compose.base.yml:../metaphactory/docker-compose.yml:../ontopic/docker-compose.yml:./docker-compose.overwrite.yml
```

For the database-bundling variants (`.env_graphdb`, `.env_rdfox`, `.env_stardog`) the rule is the same: place `../ontopic/docker-compose.yml` immediately before the trailing `./docker-compose.overwrite.yml`.

The path `../ontopic/docker-compose.yml` resolves relative to the instance folder (docker compose uses the directory of the first `COMPOSE_FILE` entry as the project directory).

### 3. Place JDBC drivers

The `ontopic-server` and `process-server` images do **not** ship JDBC drivers. They are bind-mounted from `./jdbc/` in the instance — drop the driver JARs you need into that folder.

The **H2 driver is required**: `ontopic-server` uses H2 as its internal metadata store and will **not start** without it (it fails with `Failed to load driver class org.h2.Driver`). Beyond that, add a driver for each relational data source you plan to map (e.g. PostgreSQL, MSSQL, Oracle, Snowflake, …). Use the following script to download them, e.g. from Maven Central:

```sh
<!-- in the instance folder-->
mkdir -p ./jdbc

# H2 — required (ontopic-server's internal metadata store)
H2_VERSION=2.3.232
curl -L -o "./jdbc/h2-${H2_VERSION}.jar" \
  "https://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar"

# PostgreSQL — example; add drivers for the data sources you plan to map
POSTGRES_JDBC_VERSION=42.7.4
curl -L -o "./jdbc/postgresql-${POSTGRES_JDBC_VERSION}.jar" \
  "https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_JDBC_VERSION}/postgresql-${POSTGRES_JDBC_VERSION}.jar"
```

Adjust the `*_VERSION` variables to pin the driver versions you want. The wrapper in the next step will create `./jdbc/` if it does not exist (so docker doesn't create it as root on first `up`) and prints a notice if the folder has no JARs.

### 4. Run the wrapper to set up secrets + diagnostics

Everything else is a single command:

```sh
# in the instance folder
../ontopic/init-instance-secrets.sh
```

The wrapper is **idempotent** and combines scaffolding + sanity checks:

- Scaffolds `./secrets/` from the module template (committed under [`./default-secrets/`](./default-secrets/) — an empty directory layout matching the `secrets:` definitions; the module folder is never written to at runtime). Skipped if `./secrets/` already exists.
- Runs `init-configuration-local.sh` to populate `secrets/store/db-password` (the `store-server-db` admin password).
- Creates an empty `./jdbc/` (as the current user) if missing.
- Final diagnostics: a **notice** if `./jdbc/` has no `*.jar` files.

`SECRETS_ROOT_DIR` defaults to `./secrets` (resolved against the instance directory), so docker-compose binds straight from this copy — no `.env` change needed.

As part of the init flow, `init-configuration-local.sh` sources `enable-ai.sh`, which prompts interactively for an **OpenAI** and/or **Anthropic** API key and writes whatever you provide to `secrets/ai/openai-key` / `secrets/ai/anthropic-key`. Press Enter at either prompt to skip it. `ai-server` starts either way, but the AI assistant in Ontopic Studio cannot answer until at least one key is present.

To add or change a key later without re-running init, write the matching secret file directly, e.g.:

```sh
# in the instance folder
printf '%s' "sk-..." > ./secrets/ai/openai-key   # or ./secrets/ai/anthropic-key
docker compose up -d ai-server
```

### 5. Start

```sh
# in the instance folder
docker compose up -d
```

First boot takes several minutes — the module runs six services with inter-dependent health checks. The Ontopic Studio UI is served **through metaphactory's reverse proxy** `/ontopic`, so it is reachable at `http://localhost:10214/ontopic/en-US/#` (metaphactory's host port). Ontopic does not expose its own UI host port.

## How it integrates with metaphactory

- **Networks.** metaphactory is attached to Ontopic's `application` and `databases` networks so it can reach the Ontopic services for integration purposes (`ontopic-server` lives on the `databases` network, so metaphactory can query it directly). Ontopic's internal networks (`application`, `databases`, `store-backend`) are otherwise unmodified.
- **External access.** No Ontopic service publishes a UI host port. The Ontopic Studio frontend is reached through metaphactory's reverse proxy (`MP_APP_ONTOPIC` + the frontend's `URL_PREFIX`, default `/ontopic`) at metaphactory's own host port (`10214`). The only Ontopic host port published is `ontopic-server`'s Postgres wire (`4300`), which is bound to `127.0.0.1` so it is reachable only from the docker host itself.
- **Container names.** All Ontopic containers are named `${COMPOSE_PROJECT_NAME}-ontopic-<svc>`, matching the `${COMPOSE_PROJECT_NAME}-metaphactory` pattern, so they don't collide with sibling services in the same compose project.

## Configurable env vars

The module provides sensible defaults for the following — set them in the instance `.env` only if you want to override:

| Var | Default | Purpose |
|---|---|---|
| `ONTOPIC_REPOSITORY` | `metaphacts/ontopic` | Docker Hub repository for the Ontopic-suite images |
| `ONTOPIC_VERSION` | `6.0.0` | Version part of the image tag applied to the five Ontopic-suite images |
| `VIRTUAL_HOST` | `localhost` | Domain announced by `ontopic-server` (sets `ONTOPIC_SERVER_DOMAIN`) |
| `ONTOPIC_SERVER_POSTGRES_PORT` | `4300` | ontopic-server Postgres wire port (bound to 127.0.0.1) |
| `ENABLE_MATERIALIZATION` | _(empty)_ | Set to `true` to enable materialized views; otherwise leave unset |
| `AI_SERVER_LLM_MODE` | `real` | `ai-server` LLM backend mode — `real` calls the configured provider, `mock` returns canned responses (no key needed) |
| `LLM_BASE_URL` | _(empty)_ | Override the LLM API base URL for `ai-server` (e.g. to target a self-hosted / proxy endpoint) |
| `LLM_MODELS` | _(empty)_ | Comma-separated model allow-list exposed by `ai-server`; leave empty for the image defaults |
| `ENABLE_DATA_COLLECTION` | `false` | Disable external usage/telemetry data collection |
| `URL_PREFIX` | `/ontopic` | Base path the Ontopic Studio frontend is served under |
| `LOG_SNAPSHOT_SIZE` | `false` | Log the size of project snapshots |
| `ENABLE_SCOPES` | `true` | Enable scoped projects/policies |

## Redeploying from scratch

To wipe persistent state and start over, tear down the stack and drop the named volumes (run from the instance folder):

```sh
docker compose down
docker volume rm <project>_store-db-data <project>_repos <project>_docs
docker compose up -d
```

