#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

for BUNDLE in raw delta; do
  echo "Building tarball of ${BUNDLE}/*"
  if [ -e "out/${BUNDLE}.tar" ]; then
    rm "out/${BUNDLE}.tar"
  fi
  tar cf "out/${BUNDLE}.tar" "${BUNDLE}/"
done
