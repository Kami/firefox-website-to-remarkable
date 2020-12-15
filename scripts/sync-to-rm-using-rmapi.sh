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
#
# Script which uploads all the files from the specified directory to a Remarkable
# using Remarkable cloud API via rmapi tool (https://github.com/juruen/rmapi)

RMAPI_PATH=${RMAPI_PATH:="/usr/local/bin/rmapi"}

# Directory to which web service is saving converted pdfs
DATA_PATH=${DATA_PATH:="/mnt/data/site_to_pdf_data"}

# Name of the directory on Remarkable where PDFs are saved
RM_FOLDER=${RM_FOLDER:="Website PDFs"}

# After how many minutes, old files should be deleted. Keep in mind that this needs to be more
# than the actual interval used for cron job to make sure old files are correctly delete and not
# re-added to the device.
FILE_CLEAN_INTERVAL_MINUTES="5"

if [ ! -f "${RMAPI_PATH}" ]; then
    echo "rmapi binary doesn't exist"
    echo "You can build / download it from https://github.com/juruen/rmapi"
    exit 2
fi

# 1. Delete old files
echo "Deleting old pdf files from ${DATA_PATH}"
find "${DATA_PATH}" -name "*.pdf" -type f -mmin +${FILE_CLEAN_INTERVAL_MINUTES} -delete

# 2. Upload new files
echo "Uploading new PDF files from ${DATA_PATH} to ${RM_DIRECTORY} folder on Remarkable"
${RMAPI_PATH} mkdir "${RM_FOLDER}" || true
find "${DATA_PATH}" -name "*.pdf" -print0 | xargs -0 -I {} ${RMAPI_PATH} put {} "${RM_DIRECTORY_NAME}" || true
