#!/usr/bin/env bash

set -e

if [[ -n "$BASH_VERSION" ]]; then
  echo "Using Bash"
elif [[ -n "$ZSH_VERSION" ]]; then
  echo "Using Zsh"
else
  echo "Unknown shell, bash or zsh supported"
  exit 1
fi

if [[ "$PWD" =~ \  ]]
then
  echo "Warning: path '$PWD' has spaces"
fi

# Note: skip sourcing ./.env — the instance .env is a docker-compose
# env file (unquoted values with spaces), not a bash-source-safe file, and the
# only vars used below have working fallbacks.

# Note: require ./secrets to exist (scaffold via init-instance-secrets.sh
# or `cp -R ../ontopic/default-secrets ./secrets`). Drop upstream fallback to
# ./default-secrets — that folder is not present in a service-template instance.
secrets_folder="./secrets"
if [ ! -d "$secrets_folder" ]; then
  echo "Error: $secrets_folder not found in $(pwd)." >&2
  echo "       Run ../ontopic/init-instance-secrets.sh from the instance folder," >&2
  echo "       or manually: cp -R ../ontopic/default-secrets ./secrets" >&2
  exit 1
fi


CONFIG_FILE=${CONFIG_FILE:-./.env}
SECRETS_DIR=${SECRETS_ROOT_DIR:-$secrets_folder}
VOLUMES_DIR=${VOLUMES_ROOT_DIR:-./volumes}
PORT=${VIRTUAL_PORT:-8081}
HOST=${VIRTUAL_HOST:-localhost}

echo "secrets folder $SECRETS_DIR"
echo "volumes folder $VOLUMES_DIR"
echo "configuration file $CONFIG_FILE"

# Note: source helpers from script's own dir, so this can be run from an instance folder
source "$(dirname "$0")/functions.sh"
# Set up

if  check_directory_existance "$VOLUMES_DIR"; then

if [[ -n "$BASH_VERSION" ]]; then
  read -p "Do you want to remove all data and choose databases password? (y/n):" answer_data
elif [[ -n "$ZSH_VERSION" ]]; then
  read "answer_data?Do you want to remove all data and choose databases password? (y/n):"
fi
case ${answer_data:0:1} in
    y|Y)
        echo "Removing folder $VOLUMES_DIR"
        rm -r "$VOLUMES_DIR"
        ;;
    *)
        echo "Skipped removing folder $VOLUMES_DIR"
        ;;
esac
fi

# Database

enter_section "Store" "store"

if ! check_file_existance "db-password" ||  [ "$answer_data" = "y" ]; then
read_optional "Internal Database Password" "postgres" STORE_DB_PASSWORD
write_secret "db-password" "$STORE_DB_PASSWORD"
fi
exit_section

# Note: skip the upstream `./volumes/...` bind-mount scaffolding and the matching
# `write_configuration` lines appended to .env — we use docker named volumes instead.

# Note: source helpers from script's own dir (see top of file)
source "$(dirname "$0")/enable-materialization.sh"

source  "$(dirname "$0")/enable-ai.sh"

echo -e "\033[92mOntopic Suite has been successfully configured.\033[39m"

echo -e "\033[92mLaunch the suite using the following command:\033[39m"
echo -e "\033[95mProduction (HTTP)\033[39m\tdocker compose up -d"