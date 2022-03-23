DROP TABLE IF EXISTS folio_reporting.instance_languages;

-- Create a local table for languages in instance records.
CREATE TABLE folio_reporting.instance_languages AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    languages.data #>> '{}' AS "language",
    languages.ordinality AS language_ordinality
FROM
    inventory_instances AS instances
    CROSS JOIN LATERAL json_array_elements(json_extract_path(data, 'languages')) WITH ORDINALITY AS languages (data);

CREATE INDEX ON folio_reporting.instance_languages (instance_id);

CREATE INDEX ON folio_reporting.instance_languages (instance_hrid);

CREATE INDEX ON folio_reporting.instance_languages ("language");

CREATE INDEX ON folio_reporting.instance_languages (language_ordinality);

