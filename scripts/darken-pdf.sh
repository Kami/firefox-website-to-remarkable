#!/usr/bin/env bash
# Based on https://superuser.com/posts/1538073
set -e

FILE_PATH=$1

if [ ! -f "${FILE_PATH}" ]; then
  echo "Invalid file path: ${FILE_PATH}"
  exit 2
fi

# Density ppi - the higher the value the longer the conversion will take
DENSITY=${DENSITY:-"300"}
DESTINATION_DIRECTORY=${DESTINATION_DIRECTORY:-""}

if [ -z "${DESTINATION_DIRECTORY}" ]; then
  DESTINATION_DIRECTORY=$(pwd)
fi

FILE_NAME=$(basename "${1}" ".pdf")

# NOTE: We support concurrent execution of this script so we create temporary
# directory per file and only move generated pdf to the original directory when
# we are done
TEMP_DIR=$(mktemp -d -t pdf-darken-XXXXXXXXXXXX)

clean_up() {
  popd > /dev/null

  if [ -d "${TEMP_DIR}" ]; then
    echo "Removing temporary directory ${TEMP_DIR}..."
    rm -rf "${TEMP_DIR}"
  fi
}

DESTINATION_PATH_TEMP="${TEMP_DIR}/${FILE_NAME}_darkened.pdf"
DESTINATION_PATH_FINAL="${DESTINATION_DIRECTORY}/${FILE_NAME}_darkened.pdf"

pushd "${TEMP_DIR}" > /dev/null

trap "clean_up" EXIT

echo "Darkening pdf (this may take a while)..."

# 1. Convert it to jpg images
convert -density "${DENSITY}" "${FILE_PATH}" darken_pdf_preprocess_%02d.jpg

# 2. Darken the images
echo "Darkening JPGs..."
convert darken_pdf_preprocess*.jpg -level "50%,100%,0.3" darken_pdf_postprocess_%02d.jpg

# 3. Re-create pdf from darkned jpg images
echo "Converting JPGs to PDF..."

convert darken_pdf_postprocess*.jpg -background none "${DESTINATION_PATH_TEMP}"

# 4. Move generated pdf in place (we do this to avoid potential sync issue if we wrote
# PDF directly to the output instead of temporary dir). Think of it as of an atomic movie
mv "${DESTINATION_PATH_TEMP}" "${DESTINATION_PATH_FINAL}"

echo "Darkned PDF stored at ${DESTINATION_PATH}"

# NOTE: In some cases generated PDF for some reason won't be readable on RM
# (still haven't figured out way). In that case we can convert it to epub using
# calibre. This will also result in small overall file size
# ebook-convert "${DESTINATION_PATH}" "${DESTINATION_PATH}.epub" --margin-left 0
# --margin-right 0 --margin-top 0 --margin-bottom 0 --enable-heuristics
# --output-profile tablet
