#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

set +e
INITIAL=$(ls delta | grep -v bsdiff)
set -e

if [ ! -z "$INITIAL" ]; then
  echo "Removing previous initial version, $INITIAL"
  rm "delta/$INITIAL"
fi

for VERSION in $(cd raw; ls | sort -n); do
  PREVIOUS=$(cd raw; ls | sort -n | grep -B 1 "$VERSION" | head -1)

  if [ "$PREVIOUS" -eq "$VERSION" ]; then
    if [ -e "delta/$VERSION" ]; then
      continue
    fi
    echo "Copying initial version ${VERSION}"
    cp "raw/$VERSION" delta/
    continue
  fi

  if [ -e "delta/${VERSION}.bsdiff" ]; then
    continue
  fi

  echo "Computing diff for ${PREVIOUS}..${VERSION}"
  bsdiff "raw/$PREVIOUS" "raw/$VERSION" "delta/${VERSION}.bsdiff"
done
