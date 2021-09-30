DROP TABLE IF EXISTS folio_reporting.instance_former_ids;

CREATE TABLE folio_reporting.instance_former_ids AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    json_extract_path_text(identifiers.data, 'value') AS former_instance_ids
FROM
    inventory_instances AS instances
    CROSS JOIN json_array_elements(json_extract_path(data, 'identifiers')) AS identifiers (data)
    LEFT JOIN inventory_identifier_types ON json_extract_path_text(identifiers.data, 'identifierTypeId') = inventory_identifier_types.id
WHERE
    inventory_identifier_types.name = 'former_bib_id';

CREATE INDEX ON folio_reporting.instance_former_ids (instance_id);

CREATE INDEX ON folio_reporting.instance_former_ids (instance_hrid);

CREATE INDEX ON folio_reporting.instance_former_ids (former_instance_ids);
