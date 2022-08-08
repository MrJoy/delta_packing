#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

COUNT=5000
ARTICLE="Transformers"
# ARTICLE="Recession"
# ARTICLE="United_States"

# N.B. Not handling pagination here, and having such a high limit is quite slow.
echo "Fetching list of versions..."
curl --silent "https://en.wikipedia.org/w/index.php?title=${ARTICLE}&limit=${COUNT}&action=history" | perl -pse 's/^.*?oldid=(\d+).*$/\1/gm' | grep -v -E '[<":> \s]' | grep -E '[[:digit:]]' | uniq | sort -n | while read VERSION; do
  if [ -e "raw/$VERSION" ]; then
    continue
  fi
  echo "Fetching version $VERSION"
  curl --silent "https://en.wikipedia.org/w/index.php?title=${ARTICLE}&action=raw&oldid=${VERSION}" > "raw/$VERSION"
done
