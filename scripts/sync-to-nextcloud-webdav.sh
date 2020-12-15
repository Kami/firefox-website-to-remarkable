#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Copyright 2020 Tomaz Muraus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script which adds generated pdf files to Nextcloud using curl + Nextcloud webdav endpoint.

# Directory to which web service is saving converted pdfs
DATA_PATH=${DATA_PATH:="/mnt/data/site_to_pdf_data"}
DATA_PATH=${DATA_PATH%/}

NEXTCLOUD_WEBDAV_URL=${NEXTCLOUD_WEBDAV_URL:="https://<your host>/remote.php/dav/files/<username>"}
NEXTCLOUD_WEBDAV_URL=${NEXTCLOUD_WEBDAV_URL%/}

# Nextcloud credentials used to authenticate. You are strongly recommended to enable MFA for your
# account and use application specific credentials here.
NEXTCLOUD_CREDENTIALS=${NEXTCLOUD_CREDENTIALS:="username:password"}

# Name of the webdav folder where files will be added
NEXTCLOUD_FOLDER=${NEXTCLOUD_FOLDER:="website-articles"}

# After how many minutes, old files should be deleted. Keep in mind that this needs to be more
# than the actual interval used for cron job to make sure old files are correctly delete and not
# re-added to the device.
FILE_CLEAN_INTERVAL_MINUTES="5"

# 0. Verify the credentials
curl -s --fail -X GET --user "${NEXTCLOUD_CREDENTIALS}" "${NEXTCLOUD_WEBDAV_URL}/${NEXTCLOUD_FOLDER}"

# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "nextcloud returned non 200 response. This likely indicates invalid credentials or URL."
    exit 2
fi

# 1. Delete old files
echo "Deleting old pdf files from ${DATA_PATH}"
find "${DATA_PATH}" -name "*.pdf" -type f -mmin +${FILE_CLEAN_INTERVAL_MINUTES} -delete

# 2. Create folder on nextcloud (ignore any errors if it already exists)
echo "Creating folder ${NEXTCLOUD_FOLDER} on Nextcloud"
curl -X MKCOL --user "${NEXTCLOUD_CREDENTIALS}" "${NEXTCLOUD_WEBDAV_URL}/${NEXTCLOUD_FOLDER}" || true

# 2. Add / move files to nextcloud data dir
echo "Uploading new PDF files from ${DATA_PATH} to ${NEXTCLOUD_FOLDER} folder on Nextcloud"

for file_path in "${DATA_PATH}"/*.pdf; do
    echo "Uploading file ${file_path}..."
    file_name=$(basename "${file_path}")
    curl -X PUT -T "${file_path}" --user "${NEXTCLOUD_CREDENTIALS}" "${NEXTCLOUD_WEBDAV_URL}/${NEXTCLOUD_FOLDER}/${file_name}" || true
done
