#!/bin/sh

POCKETJSON="pocket_unread.json"
INSTALOADER_PATH="${HOME}/.local/bin/instaloader"

if [ ! -f "{INSTALOADER_PATH}" ]; then
    echo "No instaloader in ${INSTALOADER_PATH}" > /dev/stderr
fi


if [ -f "${POCKETJSON}" ]; then
    grep 'instagram' < pocket_unread.json | \
	grep "resolved_url" | \
	sort | \
	awk -F '/' '{print $5}' > list
fi

xargs -I{} -P10 -n1 -t \
      "${INSTALOADER_PATH}" --filename-pattern '{filename}' -- "-{}" < list

