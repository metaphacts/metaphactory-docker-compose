#!/usr/bin/env bash
#
# Instance setup helper: scaffold the per-instance `./secrets/` folder from
# the module's `default-secrets/` template, then run init-configuration-local.sh
# to populate it with concrete values, then clean up sed `.bak` sidecars.
#
# Idempotent: re-running this script after a successful first run is a no-op
# for both the template copy and the secret population step.
#
# Run from inside a service-template instance folder. Example:
#
#   cd qa-foo
#   ../ontopic/init-instance-secrets.sh

set -e

script_dir="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f ./.env ]; then
    echo "Error: ./.env not found in $(pwd)." >&2
    echo "       Run this script from a service-template instance folder." >&2
    exit 1
fi

# Scaffold ./secrets from the module template (idempotent: skip if present).
if [ ! -d ./secrets ]; then
    echo "Scaffolding ./secrets from ${script_dir}/default-secrets ..."
    cp -R "${script_dir}/default-secrets" ./secrets
else
    echo "./secrets already exists — skipping template copy."
fi

# The upstream `check_file_existance` guard in init-configuration-local.sh
# checks file presence, not non-empty content — so the empty `db-password`
# placeholder we just copied from the template would cause the password
# prompt to be silently skipped, leaving postgres unable to start. Remove
# the zero-byte placeholder so the guard sees it as missing.
for f in ./secrets/store/db-password; do
  [ -f "$f" ] && [ ! -s "$f" ] && rm "$f"
done

if [ -s ./secrets/store/db-password ]; then
    echo "./secrets/store/db-password already populated — instance already configured, skipping init-configuration-local.sh."
    echo "To re-initialize, truncate ./secrets/store/db-password and re-run, or invoke the script directly."
else

    "${script_dir}/init-configuration-local.sh"
fi


# Pre-create the jdbc/ bind-mount source as the current user. If we leave it
# missing, docker will create it on first `up` as root, which then blocks the
# user from dropping driver JARs into it without elevation.
if [ ! -d ./jdbc ]; then
    mkdir ./jdbc
fi

# --- Final sanity checks ---


# Notice if ./jdbc has no driver JARs — ontopic-server and process-server will
# start but cannot connect to any external relational data source.
if ! ls ./jdbc/*.jar >/dev/null 2>&1; then
    echo
    echo "Notice: ./jdbc/ has no JDBC driver JARs. Drop driver JARs here (e.g."
    echo "        from the upstream Ontopic Suite jdbc/ bundle) for the DB"
    echo "        connectors you need. Until then, ontopic-server and"
    echo "        process-server will run with no JDBC connectivity."
fi

