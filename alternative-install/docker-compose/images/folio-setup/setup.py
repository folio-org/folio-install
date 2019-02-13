#!/usr/bin/env python
from time import sleep
import requests
import sys
import json
import os


def findnth(haystack, needle, n):
    parts = haystack.split(needle, n+1)
    if len(parts) <= n+1:
        return -1
    return len(haystack)-len(parts[-1])-len(needle)


def getModuleUrl(module, tag):
    try:
        url = "{0}/{1}-{2}".format(registry_module_url, module, tag)
        # print(url)
        req = requests.get(url)
        data = req.json()
        container_port = list(data["launchDescriptor"]['dockerArgs']
                              ['HostConfig']['PortBindings'].keys())[0].split('/')[0]
        return "http://{0}:{1}".format(module, container_port)
    except:
        print(
            "Warning: {0}-{1} not found in folio-registry. Port 8081 used as default".format(module, tag))
        return "http://{0}:{1}".format(module, "8081")


headers = {"Content-type": "application/json"}
# Pull OKapi register
okapi_pull_url = "{0}/_/proxy/pull/modules".format(os.environ.get('OKAPI_URL'))
data = {"urls": ["http://folio-registry.aws.indexdata.com"]}
req = requests.post(okapi_pull_url, data=json.dumps(data), headers=headers)
print("Okapi registry pull: ", req.status_code, req.text)


# create Tenant
tenant_url = "{0}/_/proxy/tenants".format(os.environ.get('OKAPI_URL'))
data = {"id": os.environ.get('OKAPI_TENANT'),
        "name": os.environ.get("TENANT_NAME"),
        "description": os.environ.get("TENANT_DESCRIPTION")}
req = requests.post(tenant_url, data=json.dumps(data), headers=headers)
print("Tenant Creation: ", req.status_code, req.text)

# Okapi internal module for the tenant
tenant_enable_url = "{0}/_/proxy/tenants/{1}/modules".format(
    os.environ.get('OKAPI_URL'), os.environ.get('OKAPI_TENANT'))
data = {"id": "okapi"}
req = requests.post(tenant_enable_url, data=json.dumps(data), headers=headers)
print("Tenant register internal Okapi Module: ", req.status_code, req.text)

# Okapi module deploy
deploy_url = os.environ.get('DEPLOY_URL')
req = requests.get(deploy_url)
data = req.json()
for itm in data:
    deploy_descriptor = {"srvcId": itm["id"], "instId": itm["id"], "url": "'"}
    count = len(itm['id'].split('-'))
    module = itm['id'][:findnth(itm['id'], '-', count-2)]
    tag = itm['id'][findnth(itm['id'], '-', count-2)+1:]
    deploy_descriptor = {"srvcId": itm["id"], "instId": itm["id"], "url": getModuleUrl(
        module, tag), "action": "enable"}
    req = requests.post("{0}/_/discovery/modules".format(os.environ.get(
        'OKAPI_URL')), data=json.dumps(deploy_descriptor), headers=headers)

#print("Timeout to allow modules to deploy")
# sleep(60)

# Get modules from okapi to enable within Tenant
# discovery_url="{0}/_/discovery/modules".format(os.environ.get('OKAPI_URL'))
# discovery_mods=requests.get(discovery_url,headers=headers).json()
# status=True
# while status:
#    status=False
#    remaining=[]
#    for itm in discovery_mods:
#       data={"id":itm["instId"]}
#        req=requests.post(tenant_enable_url,data=json.dumps(data),headers=headers)
#        print("{0} Tenant Enable: ".format(itm["instId"]),req.status_code,req.text)
#        if req.status_code >=400:
#            status=True
#            remaining.append(itm)
#    discovery_mods=remaining

# Post the list of Stripes modules to enable
enable_url = os.environ.get('ENABLE_URL')
req = requests.get(enable_url)
data = req.json()
stripes_install_url = "{0}/_/proxy/tenants/{1}/install?preRelease=false".format(
    os.environ.get('OKAPI_URL'), os.environ.get('OKAPI_TENANT'))
# with open("platform-complete/stripes-install.json", "r") as f1:
#    data=f1.read()
req = requests.post(stripes_install_url,
                    data=json.dumps(data), headers=headers)
print("Stripes module enable: ", req.status_code, req.text)
