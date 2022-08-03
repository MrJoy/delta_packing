#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

time ./pull.sh

time ./delta.sh

time ./package.sh

time ./compress.sh

echo
echo "$(ls raw | wc -l) versions"
ls -la out/
