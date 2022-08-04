#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

set +e
INITIAL=$(ls delta | grep -v bsdiff)
set -e

if [ $(ls delta | wc -l) -gt 0 ]; then
  echo "Clearing old delta chain"
  rm delta/*
fi

for VERSION in $(cd raw; ls | sort -n); do
  PREVIOUS=$(cd raw; ls | sort -n | grep -B 1 "$VERSION" | head -1)

  if [ "$PREVIOUS" -eq "$VERSION" ]; then
    echo "Copying initial version ${VERSION}"
    cp "raw/$VERSION" delta/
    continue
  fi

  echo "Computing diff candidates for ${VERSION}"
  if [ $(ls candidates | wc -l) -gt 0 ]; then
    rm candidates/*
  fi

  for CANDIDATE_VERSION in $(cd raw; ls | sort -n | grep -B 4 "$VERSION"); do
    if [ "$CANDIDATE_VERSION" -eq "$VERSION" ]; then
      cp "raw/$VERSION" candidates/
      continue
    fi

    bsdiff "raw/$CANDIDATE_VERSION" "raw/$VERSION" "candidates/${CANDIDATE_VERSION}_${VERSION}.bsdiff"
  done

  echo "Copying best candidate to delta/"
  CHOSEN_CANDIDATE=$(wc -c candidates/* | grep -v total | sort -n | head -1 | awk '{ print $2 }' | cut -d/ -f2)
  cp "candidates/$CHOSEN_CANDIDATE" delta/
done
