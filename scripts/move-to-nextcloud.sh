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

# Script which is to be used on setups where the web service runs on the same server as the
# Nextcloud instance or similar where you have access to Nextcloud data directory.
# This script assumes Remarkable is configured to periodically pull down all the files from
# a specific Nextcloud directory using rclone + systemd timer


# Directory to which web service is saving converted pdfs
DATA_PATH=${DATA_PATH:="/mnt/data/site_to_pdf_data"}

# Path to the nextcloud data directory where the files should be moved
NEXTCLOUD_PATH=${NEXTCLOUD_PATH:="/mnt/data/nextcloud/username/files/directory"}

# After how many minutes, old files should be deleted. Keep in mind that this needs to be more
# than the actual interval used for cron job to make sure old files are correctly delete and not
# re-added to the device.
FILE_CLEAN_INTERVAL_MINUTES="5"

# 1. Delete old files
echo "Deleting old pdf files from ${DATA_PATH}"
find "${DATA_PATH}" -name "*.pdf" -type f -mmin +${FILE_CLEAN_INTERVAL_MINUTES} -delete

echo "Deleting old pdf files from ${NEXTCLOUD_PATH}"
find "${NEXTCLOUD_PATH}" -name "*.pdf" -type f -mmin +${FILE_CLEAN_INTERVAL_MINUTES} -delete

# 2. Add / move files to nextcloud data dir
echo "Uploading new PDF files from ${DATA_PATH} to ${RM_DIRECTORY} folder on Remarkable"
find "${DATA_PATH}" -name "*.pdf" -print0 | xargs -0 -I {} mv {} "${NEXTCLOUD_PATH}" || true
