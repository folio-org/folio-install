#!/usr/bin/python3

import argparse
import json
import re
import sys
import urllib.request
import uuid


SUPERUSER_PERMISSIONS = [ 
    "okapi.all", 
    "okapi.proxy.pull.modules.post",
    "perms.all",
    "login.all",
    "users.all"
]

# main logic for this script goes here, functions used are defined below
def main():
    # parse arguments
    args = parse_command_line_args()
    okapi_url = args.okapi_url

    # enable mod-users, mod-permissions, mod-login
    module_ids = fetch_module_ids(['mod-users', 'mod-permissions', 'mod-login'], okapi_url)
    for k in module_ids:
        print("Enabling module {}...".format(module_ids[k]))
        enable_module(module_ids[k], okapi_url)
        print("Success")

    # Create user
    print("Creating new user: " + args.user_name)
    newuser = create_user_mod_users(args.user_name, okapi_url)
    newuser_json = json.loads(newuser)
    print("Successfully created user {} with id {}".format(args.user_name, newuser_json['id']))
    
    # Grant permissions to user
    print("Granting the following permissions to {}".format(args.user_name))
    for perm in SUPERUSER_PERMISSIONS:
        print(perm)
    add_permissions(newuser_json['id'], SUPERUSER_PERMISSIONS, okapi_url)
    
    # Create login credentials
    create_login_credentials(args.user_name, args.password, okapi_url)

    # Enable mod-authtoken
    mod_authtoken_id = fetch_module_ids(['mod-authtoken'], okapi_url)['mod-authtoken']
    print("Enablling module {}...".format(mod_authtoken_id))
    enable_module(mod_authtoken_id, okapi_url)

    #Log in and print x-okapi-token
    print("Successfully secured Okapi, logging in...")
    payload = json.dumps({
        'username': args.user_name,
        'password': args.password
    }).encode('UTF-8')

    login_headers = okapi_post(okapi_url + '/authn/login' ,payload, return_headers=True)

    print(json.dumps({
        'username': args.user_name,
        'password': args.password,
        'x-okapi-token': login_headers['x-okapi-token']
    }, indent=4))

# functions used in main() are defined here
def parse_command_line_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--user-name', help='okapi super user username', required=True)
    parser.add_argument('-p', '--password', help='okapi super user password', required=True)
    parser.add_argument('-o', '--okapi-url', help='Default http://localhost:9130',
                        default='http://localhost:9130', required=False)

    args = parser.parse_args()

    return args

# Generic GET request for Okapi
def okapi_get(url, tenant=None):
    tenant = tenant or 'supertenant'
    headers = {
        'X-Okapi-Tenant': tenant,
        'Accept': 'application/json'
    }
    r = urllib.request.urlopen(url)
    try:
        if headers == True:
            response_data = dict(r.info())
        else:
            response_data = r.read()
    except urllib.error.HTTPError as e:
        sys.exit(
            ' - '.join([
                'ERROR','GET', e.url,
                str(e.status), str(e.read())
            ]))
    return response_data

# Generic POST request for Okapi
def okapi_post(url, payload, tenant=None, return_headers=False):
    tenant = tenant or 'supertenant'
    headers = {
        'X-Okapi-Tenant':tenant,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    req = urllib.request.Request(url, data=payload, headers=headers)
    try:
        resp = urllib.request.urlopen(req)
        if return_headers == True:
            response_data = dict(resp.info())
        else:
            response_data =  resp.read()
    except urllib.error.HTTPError as e:
        sys.exit(' - '.join([
                'ERROR', 'POST', e.url,
                str(e.status), str(e.read().decode('utf-8'))
            ]))
    return response_data
    
def fetch_module_ids(module_names, okapi_url):
    module_ids = {}
    r = okapi_get(okapi_url + '/_/discovery/modules')
    all_mods = json.loads(r)

    for name in module_names:
        name_regex = re.compile(name + r'-\d.*\d$')
        for mod in all_mods:
            try:
                module_ids[name] = name_regex.search(mod['srvcId']).group()
            except AttributeError:
                pass
    
    return module_ids

def enable_module(module_id, okapi_url, tenant=None):
    tenant = tenant or 'supertenant'
    payload = json.dumps({ 
                'id' : module_id
            }).encode('UTF-8')
    return okapi_post(okapi_url +
                      '/_/proxy/tenants/{}/modules'.format(tenant),
                      payload)

def create_user_mod_users(username, okapi_url, id=None, tenant=None):
    id = id or str(uuid.uuid4())
    payload = json.dumps({
        'id' : id,
        'username': username,
        'active' : 'true'
    }).encode('UTF-8')
    return okapi_post(okapi_url + '/users', payload)

def add_permissions(id, permissions, okapi_url):
    payload = json.dumps({
        'userId' : id,
        'permissions' : permissions
    }).encode('UTF-8')
    return okapi_post(okapi_url + '/perms/users', payload)

def create_login_credentials(username, password, okapi_url):
    payload = json.dumps({
        'username': username,
        'password': password
    }).encode('UTF-8')
    return okapi_post(okapi_url + '/authn/credentials', payload)

if __name__ == "__main__":
    main()