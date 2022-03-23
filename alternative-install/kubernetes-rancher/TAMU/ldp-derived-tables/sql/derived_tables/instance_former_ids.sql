DROP TABLE IF EXISTS folio_reporting.instance_former_ids;
DROP TABLE IF EXISTS mis.instance_former_ids;

CREATE TABLE mis.instance_former_ids AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    json_extract_path_text(identifiers.data, 'value') AS former_instance_ids,
    hfi.library_name,
    hfi.library_code
FROM
    inventory_instances AS instances
    CROSS JOIN json_array_elements(json_extract_path(data, 'identifiers')) AS identifiers (data)
    LEFT JOIN inventory_identifier_types ON json_extract_path_text(identifiers.data, 'identifierTypeId') = inventory_identifier_types.id
    LEFT JOIN inventory_holdings ih ON instances.id = ih.instance_id
    LEFT JOIN mis.holdings_former_ids hfi ON ih.id = hfi.holding_id
WHERE
    inventory_identifier_types.name = 'former_bib_id'
GROUP BY
    instances.id,
    instances.hrid,
    former_instance_ids,
    hfi.library_name,
    hfi.library_code;

CREATE INDEX ON mis.instance_former_ids (instance_id);

CREATE INDEX ON mis.instance_former_ids (instance_hrid);

CREATE INDEX ON mis.instance_former_ids (former_instance_ids);

CREATE INDEX ON mis.instance_former_ids (library_name);

CREATE INDEX ON mis.instance_former_ids (library_code);
