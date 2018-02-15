-- Insert diku_admin user into mod_users
INSERT INTO diku_mod_users.users (jsonb) VALUES ('{"username":"diku_admin","id":"1ad737b0-d847-11e6-bf26-cec0c932ce01","active":true,"personal":{"lastName":"ADMINISTRATOR","firstName":"DIKU","email":"admin@diku.example.org"}}');

-- Insert user into auth_credentials
INSERT INTO diku_mod_login.auth_credentials (jsonb) VALUES ('{"userId":"1ad737b0-d847-11e6-bf26-cec0c932ce01","hash":"52DCA1934B2B32BEA274900A496DF162EC172C1E","salt":"483A7C864569B90C24A0A6151139FF0B95005B16"}');

-- Insert diku_admin user into permissions_users (auth by id)
INSERT INTO diku_mod_permissions.permissions_users (jsonb) VALUES ('{"id":"2408ae64-56ad-4177-9024-1e35fe5d895c","userId":"1ad737b0-d847-11e6-bf26-cec0c932ce01","permissions":["perms.all"]}');
