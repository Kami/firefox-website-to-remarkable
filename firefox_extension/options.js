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

async function saveOptions(e) {
  e.preventDefault();

  console.log("Saving settings...")

  browser.storage.sync.set({
    service_url: document.querySelector("#service_url").value,
    secret_key: document.querySelector("#secret_key").value,
    basic_auth_credentials: document.querySelector("#basic_auth_credentials").value
  });


  document.querySelector("#status").innerHTML = "Settings saved.";

  setTimeout(function() {
    document.querySelector("#status").innerHTML = "";
  }, 3000);
}

async function restoreOptions() {
  let settings = await browser.storage.sync.get(["service_url", "secret_key", "basic_auth_credentials"]);
  document.querySelector("#service_url").value = settings.service_url || "";
  document.querySelector("#secret_key").value = settings.secret_key || "";
  document.querySelector("#basic_auth_credentials").value = settings.basic_auth_credentials || "";
}

document.addEventListener("DOMContentLoaded", restoreOptions);
document.querySelector("form").addEventListener("submit", saveOptions);
