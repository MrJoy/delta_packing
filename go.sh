#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

./pull.sh &&
  ./delta.sh &&
  ./package.sh &&
  ./compress.sh

echo
echo "$(ls raw | wc -l) versions"
ls -la out/
