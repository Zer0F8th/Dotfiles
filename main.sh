#!/bin/bash

# Paths
script_root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
script_scripts_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/scripts
script_configs_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/config

# Run scripts from scripts directory
if [ ! -d "$script_root_dir" ]; then
  echo "Could not find script root directory: $script_root_dir"
  exit 1
fi
(bash "$script_scripts_dir"/banner.sh)
(bash "$script_scripts_dir"/setup.sh "$script_root_dir" "$script_scripts_dir" "$script_configs_dir")
