#!/usr/bin/python3

import argparse
import json
import sys
import urllib.request
import uuid

# main logic for this script goes here, functions used are defined below
def main():
    # parse arguments
    args = parse_command_line_args()
    okapi_url = args.okapi_url
    permissions = args.permissions.split(',')
    token = login_and_get_token(args.admin_user,
                                args.admin_password,
                                args.okapi_url,
                                args.tenant)

    # Create user
    id = str(uuid.uuid4())
    user_data = json.dumps({
        'id' : id,
        'username': args.user_name,
        'active' : 'true'
    }).encode('UTF-8')
    newuser = okapi_post(okapi_url + '/users', user_data, args.tenant, token=token)
    newuser_json = json.loads(newuser)
    print("Successfully created user {} with id {}".format(args.user_name,
        newuser_json['id']))

    perms_data = json.dumps({
        'userId' : newuser_json['id'],
        'permissions' : permissions
    }).encode('UTF-8')
    perms = okapi_post(okapi_url + '/perms/users', perms_data, args.tenant, token=token)
    perms_json = json.loads(perms)

    # Create login credentials
    login_creds_data = json.dumps({
        'username': args.user_name,
        'password': args.password
    }).encode('UTF-8')
    okapi_post(okapi_url + '/authn/credentials', login_creds_data, args.tenant, token=token)

    created_user = {}
    created_user['userId'] = perms_json['userId']
    created_user['permsId'] = perms_json['id']
    created_user['rpermissions'] = perms_json['permissions'] 

    return created_user

def parse_command_line_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--user-name', help='username', required=True)
    parser.add_argument('-p', '--password', help='password', required=True)
    parser.add_argument('-t', '--tenant', help='tenant to create user on', required=True)
    parser.add_argument('-P', '--permissions',
                        help='comma seperated list of permissions to assign user',
                        required=True)
    parser.add_argument('-o', '--okapi-url', help='Default http://localhost:9130',
                        default='http://localhost:9130', required=False)
    parser.add_argument('-a', '--admin-user', help='admin user with permission to create user',
                        required=False)
    parser.add_argument('-c', '--admin-password', help='password for admin user',
                        required=False)                   

    args = parser.parse_args()

    return args

def okapi_post(url, payload, tenant, token=None, return_headers=False):
    headers = {
        'X-Okapi-Tenant':tenant,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    if token:
        headers['X-Okapi-Token'] = token

    req = urllib.request.Request(url, data=payload, headers=headers)
    try:
        resp = urllib.request.urlopen(req)
        if return_headers == True:
            response_data = dict(resp.info())
        else:
            response_data =  resp.read().decode('utf-8')
    except urllib.error.HTTPError as e:
        sys.exit(' - '.join([
                'ERROR', 'POST', e.url,
                str(e.status), str(e.read().decode('utf-8'))
            ]))
    return response_data

def login_and_get_token(username, password, okapi_url, tenant):
    #Log in and print x-okapi-token
    payload = json.dumps({
        'username': username,
        'password': password
    }).encode('UTF-8')

    login_headers = okapi_post(okapi_url + '/authn/login',
        payload, tenant, return_headers=True)

    return login_headers['x-okapi-token']

if __name__ == "__main__":
    user = main()
    print(user)