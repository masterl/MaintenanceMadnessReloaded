#!/bin/bash

SCRIPTS_DIR=$( cd "$( dirname "$0" )" && pwd )
readonly SCRIPTS_DIR

PROJECT_ROOT=$( cd "$SCRIPTS_DIR/.." && pwd)
readonly PROJECT_ROOT

function main()
{
  cd "$PROJECT_ROOT" || exit

  while true; do
    find "$PROJECT_ROOT/maintenance-madness-reloaded" -type f |
    grep -E "[.]lua$" |
    entr -d bash "$SCRIPTS_DIR/entr_autotest.sh" "$PROJECT_ROOT"

    if [[ $? -eq 0 ]]; then
      exit
    fi
  done
}

main "$@"
