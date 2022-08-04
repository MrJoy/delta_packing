#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Compression results for 3,715 versions of the Transformers article, downloaded as just wikitext
# are as follows:
#
# For the delta chain (initial ver + bsdiff snapshots):
# -rw-r--r--   1 jonathonfrisby  staff    5111808 Aug  3 16:29 delta.tar
# -rw-r--r--   1 jonathonfrisby  staff    1706877 Aug  3 16:33 delta.tar.bz2
# -rw-r--r--   1 jonathonfrisby  staff    1883513 Aug  3 16:33 delta.tar.lz4
# -rw-r--r--   1 jonathonfrisby  staff    1571222 Aug  3 16:33 delta.tar.lzip
# -rw-r--r--   1 jonathonfrisby  staff    1582158 Aug  3 16:33 delta.tar.pzstd
# -rw-r--r--   1 jonathonfrisby  staff    1571420 Aug  3 16:33 delta.tar.xz
#
# For the raw data:
# -rw-r--r--   1 jonathonfrisby  staff  154850816 Aug  3 16:29 raw.tar
# -rw-r--r--   1 jonathonfrisby  staff    9512410 Aug  3 16:34 raw.tar.bz2
# -rw-r--r--   1 jonathonfrisby  staff   19959772 Aug  3 16:34 raw.tar.lz4
# -rw-r--r--   1 jonathonfrisby  staff     348775 Aug  3 16:35 raw.tar.lzip
# -rw-r--r--   1 jonathonfrisby  staff     311237 Aug  3 16:34 raw.tar.pzstd
# -rw-r--r--   1 jonathonfrisby  staff     313196 Aug  3 16:34 raw.tar.xz
#
# Early testing with a small number of versions (52) had lzip as the unambiguous winner in all
# cases.  With a significantly larger dataset, ztsd and xz both beat lzip on the raw dataset by
# about 10% -- but not on the delta chain dataset.
# for ARCHIVE in $(cd out; ls *.tar); do
#   echo "Compressing out/${ARCHIVE}"

#   cat "out/$ARCHIVE" | xz -9 --extreme --threads=0 > "out/${ARCHIVE}.xz"
#   cat "out/$ARCHIVE" | lz4 --best --sparse > "out/${ARCHIVE}.lz4"
#   cat "out/$ARCHIVE" | bzip2 -9 > "out/${ARCHIVE}.bz2"
#   cat "out/$ARCHIVE" | lzip -9 --match-length=273 > "out/${ARCHIVE}.lzip"
#   cat "out/$ARCHIVE" | zstd --ultra -22 --long=31 --force --stdout > "out/${ARCHIVE}.zstd_0"
#   cat "out/$ARCHIVE" | zstd --ultra -22 --long=31 --compress-literals --target-compressed-block-size=131072 --force --stdout > "out/${ARCHIVE}.zstd_1"
#   cat "out/$ARCHIVE" | zstd --ultra -22 --long=31 --no-compress-literals --stream-size=$(wc -c "out/$ARCHIVE") --force --stdout > "out/${ARCHIVE}.zstd_2"
# done

echo "Compressing out/delta.tar"
cat "out/delta.tar" | lzip -9 --match-length=273 > "out/delta.tar.lzip"

echo "Compressing out/raw.tar"
cat "out/raw.tar" | zstd --ultra -22 --long=31 --no-compress-literals --stream-size=$(wc -c "out/raw.tar") --force --stdout > "out/raw.tar.zstd"
