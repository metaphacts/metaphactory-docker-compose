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

# Note: require ./secrets to exist; drop upstream fallback to ./default-secrets
secrets_folder="./secrets"
if [ ! -d "$secrets_folder" ]; then
  echo "Error: $secrets_folder not found in $(pwd). Run ../ontopic/init-instance-secrets.sh first." >&2
  exit 1
fi

CONFIG_FILE=${CONFIG_FILE:-./.env}
SECRETS_DIR=${SECRETS_ROOT_DIR:-$secrets_folder}
VOLUMES_DIR=${VOLUMES_ROOT_DIR:-./volumes}

echo "secrets folder $SECRETS_DIR"
echo "volumes folder $VOLUMES_DIR"
echo "configuration file $CONFIG_FILE"

# Note: skip sourcing $CONFIG_FILE (./.env) — see init-configuration-local.sh
# Note: source helpers from script's own dir, so this can be run from an instance folder
source "$(dirname "$0")/functions.sh"


# Prompt user for ENABLE_MATERIALIZATION
read -r -p "Enable materialization? [y/n] (default: n): " answer_data
if  [ "$answer_data" = "y" ]; then
write_configuration "ENABLE_MATERIALIZATION" "true"
else
write_configuration "ENABLE_MATERIALIZATION" "false"
# Note: this script is sourced by init-configuration-local.sh, so use
# `return` to stop just this script when sourced; fall back to `exit` when run directly.
return 0 2>/dev/null || exit 0
fi

# Prompt user for storage backend choice
echo ""
echo "Select storage backend:"
echo "1) S3"
echo "2) Azure Blob Storage"
read -r -p "Enter your choice [1/2] (default: 1): " storage_choice
storage_choice=${storage_choice:-1}

if [ "$storage_choice" = "1" ]; then

  enter_section "S3" "s3"
  # Prompt user for S3_ACCESS_KEY_ID
  read -r -p "Enter the S3 access key ID: " S3_ACCESS_KEY_ID
  write_secret "access-key-id" "$S3_ACCESS_KEY_ID"

  read -r -p "Enter the S3 access key secret: " S3_ACCESS_KEY_SECRET
  write_secret "access-key-secret" "$S3_ACCESS_KEY_SECRET"

  exit_section

  # Prompt user for S3_BUCKET
  read -r -p "Enter the S3 bucket name: " S3_BUCKET
  write_configuration "S3_BUCKET" "$S3_BUCKET"

  # Prompt user for S3_REGION
  read -r -p "Enter the S3 region: " S3_REGION
  write_configuration "S3_REGION" "$S3_REGION"

elif [ "$storage_choice" = "2" ]; then

  enter_section "Azure Blob Storage" "azure-blob-storage"

  # Prompt user for Azure Storage Account Name
  read -r -p "Enter the Azure Storage account name: " AZURE_STORAGE_ACCOUNT_NAME
  write_secret "account-name" "$AZURE_STORAGE_ACCOUNT_NAME"

  # Prompt user for authentication method - account key or SAS token
  echo ""
  echo "Choose authentication method between account key and SAS token (at least one is required):"
  read -r -p "Enter the Azure Storage account key (press Enter to skip): " AZURE_STORAGE_ACCOUNT_KEY
  if [ -n "$AZURE_STORAGE_ACCOUNT_KEY" ]; then
    write_secret "account-key" "$AZURE_STORAGE_ACCOUNT_KEY"
  fi

  read -r -p "Enter the Azure Storage SAS token (press Enter to skip): " AZURE_STORAGE_SAS_TOKEN
  if [ -n "$AZURE_STORAGE_SAS_TOKEN" ]; then
    write_secret "sas-token" "$AZURE_STORAGE_SAS_TOKEN"
  fi

  # Validate that at least one authentication method was provided
  if [ -z "$AZURE_STORAGE_ACCOUNT_KEY" ] && [ -z "$AZURE_STORAGE_SAS_TOKEN" ]; then
    echo "Error: You must provide either an account key or a SAS token."
    exit 1
  fi

  exit_section

  # Prompt user for Azure container name
  read -r -p "Enter the Azure Blob Storage container name: " AZURE_CONTAINER_NAME
  write_configuration "AZURE_CONTAINER_NAME" "$AZURE_CONTAINER_NAME"

else
  echo "Invalid choice. Exiting."
  exit 1
fi

write_configuration "MATERIALIZATION_RESULT_DIR" "$VOLUMES_DIR/materialization-result"
write_configuration "MATERIALIZATION_CONFIGURATION_DIR" "$VOLUMES_DIR/materialization-configuration"

write_directories "$VOLUMES_DIR/materialization-result"
write_directories "$VOLUMES_DIR/materialization-configuration"
