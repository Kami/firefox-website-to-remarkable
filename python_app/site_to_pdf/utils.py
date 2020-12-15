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

import datetime

from urllib.parse import urlparse
from lxml.html import fromstring

import requests

from slugify import slugify


def url_to_filename(url: str):
    now = datetime.datetime.utcnow().strftime('%Y-%m-%d-%H:%M:%S')

    parsed = urlparse(url)
    title = slugify(get_website_title(url=url) or "")

    name = "%s_%s_%s.pdf" % (now, parsed.netloc.rsplit(":", 1)[0], title)

    return name


def get_website_title(url: str):
    r = requests.get(url)

    tree = fromstring(r.content)
    title = tree.findtext('.//title')

    return title
