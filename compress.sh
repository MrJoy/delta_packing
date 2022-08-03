#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Compression results for an early sample set comprising 52 versions of the Transformers article,
# downloaded as just wikitext are as follows:
#
# For the delta chain (initial ver + bsdiff snapshots):
# -rw-r--r--   1 jonathonfrisby  staff   114176 Aug  3 14:57 delta.tar
# -rw-r--r--   1 jonathonfrisby  staff    33062 Aug  3 15:20 delta.tar.bz2
# -rw-r--r--   1 jonathonfrisby  staff    38144 Aug  3 15:20 delta.tar.lz4
# -rw-r--r--   1 jonathonfrisby  staff    31850 Aug  3 15:20 delta.tar.lzip
# -rw-r--r--   1 jonathonfrisby  staff    32779 Aug  3 15:20 delta.tar.pzstd
# -rw-r--r--   1 jonathonfrisby  staff    31916 Aug  3 15:20 delta.tar.xz
#
# For the raw data:
# -rw-r--r--   1 jonathonfrisby  staff  3183104 Aug  3 14:57 raw.tar
# -rw-r--r--   1 jonathonfrisby  staff   155332 Aug  3 15:20 raw.tar.bz2
# -rw-r--r--   1 jonathonfrisby  staff   737694 Aug  3 15:20 raw.tar.lz4
# -rw-r--r--   1 jonathonfrisby  staff    24739 Aug  3 15:20 raw.tar.lzip
# -rw-r--r--   1 jonathonfrisby  staff    25691 Aug  3 15:20 raw.tar.pzstd
# -rw-r--r--   1 jonathonfrisby  staff    24824 Aug  3 15:20 raw.tar.xz
#
# In both cases, lzip produces the best result.  As such, we're sticking with that for the time
# being.  I'm recording the options used for each compression type here for posterity and ease of
# re-evaluation later.
for ARCHIVE in $(cd out; ls *.tar); do
  echo "Compressing out/${ARCHIVE}"
  # cat "$ARCHIVE" | xz -9 --extreme --threads=0 > "${ARCHIVE}.xz"
  # cat "$ARCHIVE" | lz4 --best --sparse > "${ARCHIVE}.lz4"
  # cat "$ARCHIVE" | bzip2 -9 > "${ARCHIVE}.bz2"
  # cat "$ARCHIVE" | pzstd --ultra -22 --force --stdout > "${ARCHIVE}.pzstd"

  cat "out/$ARCHIVE" | lzip -9 --match-length=273 > "out/${ARCHIVE}.lzip"
done
