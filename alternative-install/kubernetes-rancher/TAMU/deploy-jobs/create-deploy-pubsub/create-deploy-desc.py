#!/usr/bin/env python

from time import sleep
import requests
import sys
import json
import os

# Logic to parse okapi-install file to send in the request

def findnth(haystack, needle, n):
    parts = haystack.split(needle, n+1)
    if len(parts) <= n+1:
        return -1
    return len(haystack)-len(parts[-1])-len(needle)

# Determines the deployment URL with port, of the modules from your Okapi module registry

def getModuleUrl(module, tag):
    service_name = module + '-' + tag.replace(".","-").lower()
    try:
        url = "{0}/{1}-{2}".format(os.environ.get('REGISTRY_URL_PY'), module, tag)
        print("Backend module: {0}".format(url))
        req = requests.get(url)
        data = req.json()
        container_port = list(data["launchDescriptor"]['dockerArgs']['HostConfig']['PortBindings'].keys())[0].split('/')[0]
        return "http://{0}:{1}".format(service_name, container_port)
    except:
        print(
            "Warning: {0}-{1} not found in folio-registry. Port 8081 used as default".format(module, tag))
        return "http://{0}:{1}".format(service_name, "8081")

headers = {"Content-type": "application/json"}

# Load list of backend modules, parse with logic, and POST to /_/discovery/modules

data = json.loads(open("install/okapi-install.json",'r').read())
for itm in data:
    deploy_descriptor = {"srvcId": itm["id"], "instId": itm["id"], "url": "'"}
    count = len(itm['id'].split('-'))
    module = itm['id'][:findnth(itm['id'], '-', count-2)]
    tag = itm['id'][findnth(itm['id'], '-', count-2)+1:]
    deploy_descriptor = {"srvcId": itm["id"].encode("ascii"), "instId": itm["id"].encode("ascii"), "url": getModuleUrl(module, tag)}
    req = requests.post("{0}/_/discovery/modules".format(os.environ.get('OKAPI_URL_PY')), data=json.dumps(deploy_descriptor), headers=headers)

# Uncomment to see output or errors

print("Headers: {0}".format(headers))
print("Formatted deploy descriptor example: {0}".format(deploy_descriptor))
print("Module Registry URL: {0}".format(os.environ.get('REGISTRY_URL_PY')))
print("Okapi URL: {0}".format(os.environ.get('OKAPI_URL_PY')))
print("Request response: {0}".format(req))
sleep(5)