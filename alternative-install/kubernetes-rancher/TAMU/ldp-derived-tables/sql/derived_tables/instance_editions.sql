DROP TABLE IF EXISTS folio_reporting.instance_editions;

CREATE TABLE folio_reporting.instance_editions AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    editions.data #>> '{}' AS edition,
    editions.ordinality AS edition_ordinality
FROM
    inventory_instances AS instances
    CROSS JOIN LATERAL json_array_elements(json_extract_path(data, 'editions'))
    WITH ORDINALITY AS editions (data);

CREATE INDEX ON folio_reporting.instance_editions (instance_id);

CREATE INDEX ON folio_reporting.instance_editions (instance_hrid);

CREATE INDEX ON folio_reporting.instance_editions (edition);

CREATE INDEX ON folio_reporting.instance_editions (edition_ordinality);

