/**
 * Copyright 2020 Tomaz Muraus
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
**/

async function sendWebsiteUrlToWebService(serviceUrl, secret, basicAuthCredentials, url) {
  let params = {"secret": secret};
  let queryString = new URLSearchParams(params).toString();
  let data = JSON.stringify({"url": url});

  let request = new XMLHttpRequest();

  request.open("POST", serviceUrl + "?" + queryString);
  request.setRequestHeader("Content-Type", "application/json");

  if (basicAuthCredentials) {
    request.setRequestHeader("Authorization", "Basic " + btoa(basicAuthCredentials));
  }

  request.overrideMimeType("text/plain");
  request.send(data);
}

async function main() {
  let tabs = await browser.tabs.query({currentWindow: true, active: true});

  if (!tabs || tabs.length === 0) {
    console.log("No active tabs found");
    return;
  }

  let tab = tabs[0];

  if (!tab.url || (!tab.url.startsWith("http://") && !tab.url.startsWith("https://"))) {
    console.log("Url \"%s\" is not valid", tab.url)
    return;
  }

  let url = tab.url;
  let settings = await browser.storage.sync.get(["service_url", "secret_key", "basic_auth_credentials"]);

  console.log("Requesting webservice to convert URL \"%s\" to PDF...", url);
  await sendWebsiteUrlToWebService(settings.service_url, settings.secret_key,
    settings.basic_auth_credentials, url);
}

main();
