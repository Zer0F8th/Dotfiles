#!/bin/bash

# Paths
script_root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
script_scripts_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/scripts
script_configs_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/config
mkdir "$script_root_dir"/logs
script_logs_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/logs

# Run scripts from scripts directory
if [ ! -d "$script_root_dir" ]; then
  echo "Could not find script root directory: $script_root_dir"
  exit 1
fi
(bash "$script_scripts_dir"/banner.sh) |& tee "$script_logs_dir"/0-banner.log
(bash "$script_scripts_dir"/setup.sh "$script_root_dir" "$script_scripts_dir" "$script_configs_dir") |& tee "$script_logs_dir"/1-setup.log
