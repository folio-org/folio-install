DROP TABLE IF EXISTS folio_reporting.instance_alternative_titles;

-- Create a derived table for alternative titles from instance records with the type id and name included.
CREATE TABLE folio_reporting.instance_alternative_titles AS
SELECT
    instance.id AS instance_id,
    instance.hrid AS instance_hrid,
    json_extract_path_text(alternative_titles.data, 'alternativeTitle') AS alternative_title,
    json_extract_path_text(alternative_titles.data, 'alternativeTitleTypeId') AS alternative_title_type_id,
    inventory_alternative_title_types.name AS alternative_title_type_name
FROM
    inventory_instances AS instance
    CROSS JOIN json_array_elements(json_extract_path(instance.data, 'alternativeTitles')) AS alternative_titles(data)
    LEFT JOIN inventory_alternative_title_types ON json_extract_path_text(alternative_titles.data, 'alternativeTitleTypeId') = inventory_alternative_title_types.id;

CREATE INDEX ON folio_reporting.instance_alternative_titles (instance_id);

CREATE INDEX ON folio_reporting.instance_alternative_titles (instance_hrid);

CREATE INDEX ON folio_reporting.instance_alternative_titles (alternative_title);

CREATE INDEX ON folio_reporting.instance_alternative_titles (alternative_title_type_id);

CREATE INDEX ON folio_reporting.instance_alternative_titles (alternative_title_type_name);

