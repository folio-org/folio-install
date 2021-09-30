DROP TABLE IF EXISTS folio_reporting.users_addresses;

-- Create a derived table that takes the user_users table and unpacks
-- the address array into a normalized table
CREATE TABLE folio_reporting.users_addresses AS
SELECT
    uu.id AS user_id,
    json_extract_path_text(addresses.data, 'id') AS address_id,
    json_extract_path_text(addresses.data, 'countryId') AS address_country_id,
    json_extract_path_text(addresses.data, 'addressLine1') AS address_line_1,
    json_extract_path_text(addresses.data, 'addressLine2') AS address_line_2,
    json_extract_path_text(addresses.data, 'city') AS address_city,
    json_extract_path_text(addresses.data, 'region') AS address_region,
    json_extract_path_text(addresses.data, 'postalCode') AS address_postal_code,
    json_extract_path_text(addresses.data, 'addressTypeId') AS address_type_id,
    ua.address_type AS address_type_name,
    ua.desc AS address_type_description,
    json_extract_path_text(addresses.data, 'primaryAddress')::boolean AS is_primary_address
FROM
    user_users AS uu
    CROSS JOIN json_array_elements(json_extract_path(data, 'personal', 'addresses')) AS addresses (data)
    LEFT JOIN user_addresstypes AS ua ON json_extract_path_text(addresses.data, 'addressTypeId') = ua.id;

CREATE INDEX ON folio_reporting.users_addresses (user_id);

CREATE INDEX ON folio_reporting.users_addresses (address_id);

CREATE INDEX ON folio_reporting.users_addresses (address_country_id);

CREATE INDEX ON folio_reporting.users_addresses (address_line_1);

CREATE INDEX ON folio_reporting.users_addresses (address_line_2);

CREATE INDEX ON folio_reporting.users_addresses (address_city);

CREATE INDEX ON folio_reporting.users_addresses (address_region);

CREATE INDEX ON folio_reporting.users_addresses (address_postal_code);

CREATE INDEX ON folio_reporting.users_addresses (address_type_id);

CREATE INDEX ON folio_reporting.users_addresses (address_type_name);

CREATE INDEX ON folio_reporting.users_addresses (address_type_description);

CREATE INDEX ON folio_reporting.users_addresses (is_primary_address);

