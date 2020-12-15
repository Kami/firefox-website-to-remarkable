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

import os
import logging
import urllib

import pdfkit

from flask import Blueprint
from flask import request

from site_to_pdf.utils import url_to_filename

LOG = logging.getLogger(__name__)

convert_app = Blueprint("convert", __name__, url_prefix="/v1/convert")

# Secret which needs to be provided with each request as part of the path
SECRET = os.environ.get("SERVICE_SECRET", "")

# Path where pdf files are saved
DESTINATION_PATH = os.environ.get("DESTINATION_PATH", "/data")

# Flags passed to pdfkit binary
PDFKIT_OPTIONS = {
    "--grayscale": None
}

if not SECRET:
    raise ValueError("SERVICE_SECRET environment variable is not set!")

if not os.path.isdir(DESTINATION_PATH):
    raise ValueError("Destination path %s doesn't exist or it's not a directory")

if not os.access(DESTINATION_PATH, os.W_OK):
    raise ValueError("Destination path %s is not writable")


@convert_app.route("", methods=["POST"])
def website_to_pdf():
    secret = request.args.get('secret')

    if not SECRET or secret != SECRET:
        LOG.info("Received invalid or missing secret, aborting request")
        return "Invalid or missing secret", 403, {}

    data = request.get_json()
    url = data.get("url", None)

    if not url:
        return "", 400, {}

    file_name = url_to_filename(url)
    file_path = os.path.join(DESTINATION_PATH, file_name)

    # Convert website to PDF
    print("Converting URL %s to PDF..." % (url))

    try:
        pdfkit.from_url(url, file_path, options=PDFKIT_OPTIONS)
    except IOError as e:
        print(e)

    print("Converted file saved to %s" % (file_path))
    return "Success!", 200, {}
