DROP TABLE IF EXISTS folio_reporting.holdings_ext;

-- Create an extended holdings table which includes the name for call number type, holdings type, interlibrary loan policy, 
-- permanent location, and temporary location.
-- Holdings notes are in a separate derived table.
CREATE TABLE folio_reporting.holdings_ext AS
WITH holdings AS (
    SELECT
        id,
        hrid,
        json_extract_path_text(data, 'acquisitionMethod') AS acquisition_method,
        call_number,
        json_extract_path_text(data, 'callNumberPrefix') AS call_number_prefix,
        json_extract_path_text(data, 'callNumberSuffix') AS call_number_suffix,
        call_number_type_id,
        json_extract_path_text(data, 'copyNumber') AS copy_number,
        json_extract_path_text(data, 'holdingsTypeId') AS holdings_type_id,
        json_extract_path_text(data, 'illPolicyId') AS ill_policy_id,
        instance_id,
        permanent_location_id,
        json_extract_path_text(data, 'receiptStatus') AS receipt_status,
        json_extract_path_text(data, 'retentionPolicy') AS retention_policy,
        json_extract_path_text(data, 'shelvingTitle') AS shelving_title,
        json_extract_path_text(data, 'discoverySuppress')::boolean AS discovery_suppress,
        json_extract_path_text(data, 'metadata', 'createdDate') AS created_date,
        json_extract_path_text(data, 'metadata', 'updatedByUserId') AS updated_by_user_id,
        json_extract_path_text(data, 'metadata', 'updatedDate') AS updated_date,
        json_extract_path_text(data, 'temporaryLocationId') AS temporary_location_id
    FROM
        inventory_holdings
)
SELECT
    holdings.id AS holdings_id,
    holdings.hrid AS holdings_hrid,
    holdings.acquisition_method,
    holdings.call_number,
    holdings.call_number_prefix,
    holdings.call_number_suffix,
    holdings.call_number_type_id,
    holdings_call_number_type.name AS call_number_type_name,
    holdings.copy_number,
    holdings.holdings_type_id AS type_id,
    holdings_type.name AS type_name,
    holdings.ill_policy_id,
    json_extract_path_text(holdings_ill_policy.data, 'name') AS ill_policy_name,
    holdings.instance_id,
    holdings.permanent_location_id,
    holdings_permanent_location.name AS permanent_location_name,
    holdings.temporary_location_id,
    holdings_temporary_location.name AS temporary_location_name,
    holdings.receipt_status,
    holdings.retention_policy,
    holdings.shelving_title,
    holdings.discovery_suppress,
    holdings.created_date,
    holdings.updated_by_user_id,
    holdings.updated_date
FROM
    holdings
    LEFT JOIN inventory_holdings_types AS holdings_type ON holdings.holdings_type_id = holdings_type.id
    LEFT JOIN inventory_ill_policies AS holdings_ill_policy ON holdings.ill_policy_id = holdings_ill_policy.id
    LEFT JOIN inventory_call_number_types AS holdings_call_number_type ON holdings.call_number_type_id = holdings_call_number_type.id
    LEFT JOIN inventory_locations AS holdings_permanent_location ON holdings.permanent_location_id = holdings_permanent_location.id
    LEFT JOIN inventory_locations AS holdings_temporary_location ON holdings.temporary_location_id = holdings_temporary_location.id;

CREATE INDEX ON folio_reporting.holdings_ext (holdings_id);

CREATE INDEX ON folio_reporting.holdings_ext (holdings_hrid);

CREATE INDEX ON folio_reporting.holdings_ext (acquisition_method);

CREATE INDEX ON folio_reporting.holdings_ext (call_number);

CREATE INDEX ON folio_reporting.holdings_ext (call_number_prefix);

CREATE INDEX ON folio_reporting.holdings_ext (call_number_suffix);

CREATE INDEX ON folio_reporting.holdings_ext (call_number_type_id);

CREATE INDEX ON folio_reporting.holdings_ext (call_number_type_name);

CREATE INDEX ON folio_reporting.holdings_ext (copy_number);

CREATE INDEX ON folio_reporting.holdings_ext (type_id);

CREATE INDEX ON folio_reporting.holdings_ext (type_name);

CREATE INDEX ON folio_reporting.holdings_ext (ill_policy_id);

CREATE INDEX ON folio_reporting.holdings_ext (ill_policy_name);

CREATE INDEX ON folio_reporting.holdings_ext (instance_id);

CREATE INDEX ON folio_reporting.holdings_ext (permanent_location_id);

CREATE INDEX ON folio_reporting.holdings_ext (permanent_location_name);

CREATE INDEX ON folio_reporting.holdings_ext (temporary_location_id);

CREATE INDEX ON folio_reporting.holdings_ext (temporary_location_name);

CREATE INDEX ON folio_reporting.holdings_ext (receipt_status);

CREATE INDEX ON folio_reporting.holdings_ext (retention_policy);

CREATE INDEX ON folio_reporting.holdings_ext (shelving_title);

CREATE INDEX ON folio_reporting.holdings_ext (discovery_suppress);

CREATE INDEX ON folio_reporting.holdings_ext (created_date);

CREATE INDEX ON folio_reporting.holdings_ext (updated_by_user_id);

CREATE INDEX ON folio_reporting.holdings_ext (updated_date);

