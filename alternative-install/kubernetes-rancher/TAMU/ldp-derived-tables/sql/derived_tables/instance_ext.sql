DROP TABLE IF EXISTS folio_reporting.instance_ext;

-- Create a local table that includes the name for the mode of
-- issuance, resource type, and statuses.
CREATE TABLE folio_reporting.instance_ext AS
SELECT
    instance.id AS instance_id,
    instance.hrid AS instance_hrid,
    json_extract_path_text(instance.data, 'catalogedDate') AS cataloged_date,
    instance.title,
    instance.index_title,
    instance.instance_type_id AS type_id,
    instance_type.name AS type_name,
    instance.mode_of_issuance_id,
    mode_of_issuance.name AS mode_of_issuance_name,
    json_extract_path_text(instance.data, 'previouslyHeld')::boolean AS previously_held,
    instance.source AS instance_source,
    json_extract_path_text(instance.data, 'discoverySuppress')::boolean AS discovery_suppress,
    json_extract_path_text(instance.data, 'staffSuppress')::boolean AS staff_suppress,
    json_extract_path_text(instance.data, 'statusId') AS status_id,
    instance_status.name AS status_name,
    instance.status_updated_date,
    json_extract_path_text(instance.data, 'source') AS record_source,
    json_extract_path_text(instance.data, 'metadata', 'createdDate') AS record_created_date,
    json_extract_path_text(instance.data, 'metadata', 'updatedByUserId') AS updated_by_user_id,
    json_extract_path_text(instance.data, 'metadata', 'updatedDate') AS updated_date
FROM
    inventory_instances AS instance
    LEFT JOIN inventory_instance_types AS instance_type ON instance.instance_type_id = instance_type.id
    LEFT JOIN inventory_modes_of_issuance AS mode_of_issuance ON instance.mode_of_issuance_id = mode_of_issuance.id
    LEFT JOIN inventory_instance_statuses AS instance_status ON json_extract_path_text(instance.data, 'statusId') = instance_status.id;

CREATE INDEX ON folio_reporting.instance_ext (instance_id);

CREATE INDEX ON folio_reporting.instance_ext (instance_hrid);

CREATE INDEX ON folio_reporting.instance_ext (cataloged_date);

--CREATE INDEX ON folio_reporting.instance_ext (title);

--CREATE INDEX ON folio_reporting.instance_ext (index_title);

CREATE INDEX ON folio_reporting.instance_ext (type_id);

CREATE INDEX ON folio_reporting.instance_ext (type_name);

CREATE INDEX ON folio_reporting.instance_ext (mode_of_issuance_id);

CREATE INDEX ON folio_reporting.instance_ext (mode_of_issuance_name);

CREATE INDEX ON folio_reporting.instance_ext (previously_held);

CREATE INDEX ON folio_reporting.instance_ext (instance_source);

CREATE INDEX ON folio_reporting.instance_ext (discovery_suppress);

CREATE INDEX ON folio_reporting.instance_ext (staff_suppress);

CREATE INDEX ON folio_reporting.instance_ext (status_id);

CREATE INDEX ON folio_reporting.instance_ext (status_name);

CREATE INDEX ON folio_reporting.instance_ext (status_updated_date);

CREATE INDEX ON folio_reporting.instance_ext (record_source);

CREATE INDEX ON folio_reporting.instance_ext (record_created_date);

CREATE INDEX ON folio_reporting.instance_ext (updated_by_user_id);

CREATE INDEX ON folio_reporting.instance_ext (updated_date);
