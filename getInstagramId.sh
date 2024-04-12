#!/bin/sh

POCKETJSON="pocket_unread.json"
INSTALOADER_PATH="${HOME}/.local/bin/instaloader"

if [ ! -x "${INSTALOADER_PATH}" ]; then
    echo "No instaloader in ${INSTALOADER_PATH}" > /dev/stderr
    exit 1
fi

if [ -f "${POCKETJSON}" ]; then
    grep 'instagram' < pocket_unread.json | \
	grep "resolved_url" | \
	sort | \
	awk -F '/' '{print $5}' > list
else
    echo "No ${POCKETJSON}." > /dev/stderr
    exit 2
fi

# make Image Dir
IMAGEDIR="images"
mkdir "${IMAGEDIR}"
if [ ! -d "${IMAGEDIR}/" ]; then
    echo "Can't makedir ${IMAGEDIR}. halt." > /dev/stderr
    exit 3
fi

# make Temporary Dirs
TEMPDIR="temp"
mkdir "${TEMPDIR}"
if [ ! -d "${TEMPDIR}/" ]; then
    echo "Can't makedir ${TEMPDIR}. halt." > /dev/stderr
    exit 4
fi

# make download target instagram article IDs from pocket URL
grep 'instagram' < "${POCKETJSON}" | \
    grep "resolved_url" | \
    sort | awk -F '/' '{print $5}' > list

LISTCOUNT=$(wc -l < list)
if [ "${LISTCOUNT}" -le 0 ]; then
    echo "No instagram URL found."  > /dev/stderr
    exit 0
fi
echo "There are ${LISTCOUNT} URLs found."

# Download Image into images/ dir
DIRNAME_PATTERN="${TEMPDIR}/{target}"
while read -r id; do
echo "Downloading ${id}."
"${INSTALOADER_PATH}" \
    --dirname-pattern "${DIRNAME_PATTERN}" \
    --filename-pattern '{filename}' -- \
    "-${id}"
done < list

# Get Pocket Article ID from pocket JSON
xargs -I{} -n1 grep -B 14 {} "${POCKETJSON}" < list | \
    grep 'item_id' | awk -F: '{print $2}' | \
    tr -d '", ' > remove_pocket_id.txt

# Move Photo and Texts on the directory into imagedir/
find "${TEMPDIR}/" -type f -exec mv {} ${IMAGEDIR}/ \;

# Remove Wastes.
rm -fv "${IMAGEDIR}/*.xz" "${IMAGEDIR}/*.txt"

# Make Archives
DATE=$(date +%Y%m%d)
zip "Instagram_${DATE}.zip" "${IMAGEDIR}/"
