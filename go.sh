#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Fetching any new versions..."
time ./pull.sh
echo

echo "Computing diffs..."
time ./delta.sh
echo

echo "Build tarballs..."
time ./package.sh
echo

echo "Compressing tarballs..."
time ./compress.sh
echo

echo "$(ls raw | wc -l) versions"

echo
ls -la out/
