#!/bin/bash

set -e

if [[ -n "$BASH_VERSION" ]]; then
  echo "Using Bash"
elif [[ -n "$ZSH_VERSION" ]]; then
  echo "Using Zsh"
else
  echo "Unknown shell, bash or zsh supported"
  exit 1
fi

secrets_folder="./secrets"
if ! [ -d "$secrets_folder" ]
then
  secrets_folder="./default-secrets"
fi

CONFIG_FILE=${CONFIG_FILE:-./.env}
SECRETS_DIR=${SECRETS_ROOT_DIR:-$secrets_folder}
VOLUMES_DIR=${VOLUMES_ROOT_DIR:-./volumes}

echo "secrets folder $SECRETS_DIR"
echo "volumes folder $VOLUMES_DIR"
echo "configuration file $CONFIG_FILE"

# Note: skip sourcing $CONFIG_FILE (./.env) — the instance .env is a
# docker-compose env file (unquoted values with spaces, JVM -D args), not a
# bash-source-safe file. The vars used below have working fallbacks.

# Note: source helpers from script's own dir, so this works when run
# from an instance folder or sourced by init-configuration-local.sh
source "$(dirname "$0")/functions.sh"

enter_section "AI" "ai"

# Prompt user for OpenAI API key
read -r -p "Enter the OpenAI API key (press Enter to skip): " OPENAI_API_KEY
if [ -n "$OPENAI_API_KEY" ]; then
  write_secret "openai-key" "$OPENAI_API_KEY"
fi

# Prompt user for Anthropic API key
read -r -p "Enter the Anthropic API key (press Enter to skip): " ANTHROPIC_API_KEY
if [ -n "$ANTHROPIC_API_KEY" ]; then
  write_secret "anthropic-key" "$ANTHROPIC_API_KEY"
fi

# Validate that at least one API key was provided
if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ] \
    && ! check_file_existance "openai-key" \
    && ! check_file_existance "anthropic-key"; then
  echo "Notice: no OpenAI/Anthropic API key configured; ai-server will run but the AI assistant in Ontopic Studio will be unavailable until a key is provided."
fi

exit_section


