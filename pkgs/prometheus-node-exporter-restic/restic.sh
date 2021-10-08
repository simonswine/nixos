#!/bin/sh

set -eu

NAMESPACE=restic

BACKUP_FOLDER=/var/lib/restic

SNAPSHOTS_DIRS=$(find ${BACKUP_FOLDER} -mindepth 2 -maxdepth 4 -name snapshots -type d)

OUTPUT=""

for snapshots_dir in ${SNAPSHOTS_DIRS}; do
   dir=$(dirname "${snapshots_dir}")

   # check if there are data/index directories and a config file
   test -d "${dir}/index" || continue
   test -d "${dir}/data" || continue
   test -f "${dir}/config" || continue

   # check if the backup should be ignored
   { test -e "${dir}/.promignore" && continue; } || true

   total_size=$(du -s "${dir}" | cut -f 1)

   snapshots_raw=$(find "${dir}/snapshots" -mindepth 1 -maxdepth 2  -type f -printf "%T@ %p\n" | sort -n)
   snapshots_count=$(echo "${snapshots_raw}" | wc -l)
   latest_snapshot_unix=$(echo "${snapshots_raw}" | tail -n 1 | cut -f 1 -d ' ')

   OUTPUT="${OUTPUT}${NAMESPACE}_repository_size_bytes{repository=\"${dir}\"} ${total_size}\n"
   OUTPUT="${OUTPUT}${NAMESPACE}_snapshots_count{repository=\"${dir}\"}  ${snapshots_count}\n"
   OUTPUT="${OUTPUT}${NAMESPACE}_latest_snapshot_time_seconds{repository=\"${dir}\"} ${latest_snapshot_unix}\n"
done

echo -ne $OUTPUT | sort
