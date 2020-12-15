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

# TODO: Use base builder image to speed it up

FROM python:3.9.1-slim-buster

WORKDIR /app

RUN apt-get update -y
# Needed by pdfkit
RUN apt-get install -y wkhtmltopdf
# Needed by lxml
RUN apt-get install -y build-essential libxml2-dev libxslt-dev libxmlsec1 lib32z1-dev

RUN pip install --upgrade pip
COPY ./requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Copy app files
COPY . /app

EXPOSE 8000/tcp
ENTRYPOINT ["/app/bin/site-to-pdf"]
