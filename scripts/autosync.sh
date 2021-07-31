#!/bin/bash

SCRIPTS_DIR=$( cd "$( dirname "$0" )" && pwd )
readonly SCRIPTS_DIR

PROJECT_ROOT=$( cd "$SCRIPTS_DIR/.." && pwd)
readonly PROJECT_ROOT

MAIN_MOD_FOLDER=$(cd "$SCRIPTS_DIR/../maintenance-madness-reloaded" && pwd)
readonly MAIN_MOD_FOLDER



function main()
{
  while true; do
    find "$MAIN_MOD_FOLDER" -type f |
    entr -d bash "$SCRIPTS_DIR/entr_script.sh" "$PROJECT_ROOT"

    if [[ $? -eq 0 ]]; then
      exit
    fi
  done
}

main "$@"
