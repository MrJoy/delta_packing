#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Compression results for 3,717 versions of the Transformers article, downloaded as just wikitext
# are as follows:
#
# For the delta chain (initial ver + diff (minimal, unified, 0-context) snapshots):
# % ls -laS out/delta*
# -rw-r--r--  1 jonathonfrisby  staff  9393664 Aug  7 18:36 out/delta.tar
# -rw-r--r--  1 jonathonfrisby  staff  1376733 Aug  7 18:36 out/delta.tar.zip
# -rw-r--r--  1 jonathonfrisby  staff  1373471 Aug  7 18:36 out/delta.tar.gz
# -rw-r--r--  1 jonathonfrisby  staff  1343476 Aug  7 18:36 out/delta.tar.lz4
# -rw-r--r--  1 jonathonfrisby  staff   598998 Aug  7 18:36 out/delta.tar.bz2
# -rw-r--r--  1 jonathonfrisby  staff   266948 Aug  7 18:36 out/delta.tar.zstd_1
# -rw-r--r--  1 jonathonfrisby  staff   257452 Aug  7 18:36 out/delta.tar.zstd_0
# -rw-r--r--  1 jonathonfrisby  staff   246660 Aug  7 18:36 out/delta.tar.xz
# -rw-r--r--  1 jonathonfrisby  staff   245945 Aug  7 18:36 out/delta.tar.lzip
#
# For the raw data:
# % ls -laS out/raw*
# -rw-r--r--  1 jonathonfrisby  staff  154996224 Aug  7 18:39 out/raw.tar
# -rw-r--r--  1 jonathonfrisby  staff   46309069 Aug  7 18:39 out/raw.tar.gz
# -rw-r--r--  1 jonathonfrisby  staff   46238590 Aug  7 18:39 out/raw.tar.zip
# -rw-r--r--  1 jonathonfrisby  staff   20021279 Aug  7 18:40 out/raw.tar.lz4
# -rw-r--r--  1 jonathonfrisby  staff    9531127 Aug  7 18:40 out/raw.tar.bz2
# -rw-r--r--  1 jonathonfrisby  staff     349469 Aug  7 18:41 out/raw.tar.lzip
# -rw-r--r--  1 jonathonfrisby  staff     313540 Aug  7 18:40 out/raw.tar.xz
# -rw-r--r--  1 jonathonfrisby  staff     311031 Aug  7 18:41 out/raw.tar.zstd_0
# -rw-r--r--  1 jonathonfrisby  staff     298842 Aug  7 18:41 out/raw.tar.zstd_1
#
# Early testing with a small number of versions (52) had lzip as the unambiguous winner in all
# cases.  With a significantly larger dataset, ztsd and xz both beat lzip on the raw dataset by
# about 10% -- but not on the delta chain dataset.  Despite moving away from bsdiff (which does
# bzip2 compression of its own), lzip continues to the be the winnder for the delta chain.

# rm out/*.tar.*
# for ARCHIVE in $(cd out; ls *.tar); do
#   echo "Compressing out/${ARCHIVE}"

#   cat "out/$ARCHIVE" | gzip -9 - > "out/${ARCHIVE}.gz"
#   zip -9 "out/${ARCHIVE}.zip" "out/$ARCHIVE"
#   cat "out/$ARCHIVE" | xz -9 --extreme --threads=0 > "out/${ARCHIVE}.xz"
#   cat "out/$ARCHIVE" | lz4 --best --sparse > "out/${ARCHIVE}.lz4"
#   cat "out/$ARCHIVE" | bzip2 -9 > "out/${ARCHIVE}.bz2"
#   cat "out/$ARCHIVE" | lzip -9 --match-length=273 > "out/${ARCHIVE}.lzip"
#   cat "out/$ARCHIVE" | zstd --ultra -22 --long=31 --compress-literals --target-compressed-block-size=131072 --force --stdout > "out/${ARCHIVE}.zstd_0"
#   cat "out/$ARCHIVE" | zstd --ultra -22 --long=31 --no-compress-literals --stream-size=$(wc -c "out/$ARCHIVE") --force --stdout > "out/${ARCHIVE}.zstd_1"
# done

echo "Compressing out/delta.tar"
cat "out/delta.tar" | lzip -9 --match-length=273 > "out/delta.tar.lzip"

echo "Compressing out/raw.tar"
cat "out/raw.tar" | zstd --ultra -22 --long=31 --no-compress-literals --stream-size=$(wc -c "out/raw.tar") --force --stdout > "out/raw.tar.zstd"
