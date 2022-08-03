#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# N.B. Not handling pagination here, and having such a high limit is quite slow.
echo "Fetching list of versions..."
curl --silent 'https://en.wikipedia.org/w/index.php?title=Transformers&limit=5000&action=history' | perl -pse 's/^.*?oldid=(\d+).*$/\1/gm' | grep -v -E '[<":> \s]' | grep -E '[[:digit:]]' | uniq | while read VERSION; do
  if [ -e "raw/$VERSION" ]; then
    continue
  fi
  echo "Fetching version ${VERSION}"
  curl --silent "https://en.wikipedia.org/w/index.php?title=Transformers&action=raw&oldid=${VERSION}" > "raw/$VERSION"
done
