#!/bin/bash

enter_section() {
  local name="$1"
  local folder="$2"

  if [[ "${folder}" ]]; then
    local path_dir="$SECRETS_DIR/$folder"

    if [[ ! -d "$path_dir" ]]; then
      mkdir -p "$path_dir";
    fi

    export prefix="$path_dir"
  fi

  echo "$name"
  echo "--------"
}

exit_section() {
  unset prefix
  echo
}

read_optional() {
  local prompt="$1"
  local default="$2"
  local var="$3"
  if [[ -n "$BASH_VERSION" ]]; then
   read -p "$prompt [$default]: " -r "${var?}"
   export "$var"="${!var:-$default}"
  elif [[ -n "$ZSH_VERSION" ]]; then
   read -r "reply?${prompt} [$default]: "
   export "$var=${reply:-$default}"
  fi
}

write_secret() {
  local fname="$1"
  local val="$2"
  echo -n "$val" > "$prefix/$fname"
}

ensure_secret() {
  local fname="$1"
  local path_dir="$prefix/$fname"
  if [[ ! -f "$path_dir" ]]; then
    touch "$path_dir"
  fi
}

check_file_existance() {
  local fname="$1"
  local path_dir="$prefix/$fname"
  if [[ ! -f "$path_dir" ]]; then
    return 1
    else return 0
  fi
}

check_directory_existance() {
  local fname="$1"
  if [[ ! -d "$fname" ]]; then
    return 1
    else return 0
  fi
}

write_configuration() {
  local name="$1"
  local val="$2"
  echo "$name=$val" >> "$CONFIG_FILE"
}

write_directories() {
  local folder="$1"

  if [[ ! -d "$folder" ]]; then
    mkdir -p "$folder";
  fi

}
