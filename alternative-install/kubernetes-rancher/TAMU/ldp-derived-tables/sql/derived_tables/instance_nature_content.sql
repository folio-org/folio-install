DROP TABLE IF EXISTS folio_reporting.instance_nature_content;

CREATE TABLE folio_reporting.instance_nature_content AS
WITH nature_content AS (
    SELECT
        id AS instance_id,
        hrid AS instance_hrid,
        nature_of_content_term_ids.data #>> '{}' AS nature_of_content_term_id
    FROM
        inventory_instances
        CROSS JOIN json_array_elements(json_extract_path(data, 'natureOfContentTermIds')) AS nature_of_content_term_ids (data)
)
SELECT
    nature_content.instance_id,
    nature_content.instance_hrid,
    nature_content.nature_of_content_term_id,
    nature_content_term.name AS nature_of_content_term_name,
    nature_content_term.source AS nature_of_content_term_source
FROM
    nature_content
    JOIN inventory_nature_of_content_terms AS nature_content_term ON nature_content_term.id = nature_content.nature_of_content_term_id;

CREATE INDEX ON folio_reporting.instance_nature_content (instance_id);

CREATE INDEX ON folio_reporting.instance_nature_content (instance_hrid);

CREATE INDEX ON folio_reporting.instance_nature_content (nature_of_content_term_id);

CREATE INDEX ON folio_reporting.instance_nature_content (nature_of_content_term_name);

CREATE INDEX ON folio_reporting.instance_nature_content (nature_of_content_term_source);

