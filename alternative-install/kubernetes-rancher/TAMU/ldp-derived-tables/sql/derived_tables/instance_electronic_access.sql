DROP TABLE IF EXISTS folio_reporting.instance_electronic_access;

-- Create table for electronic access points for instance records that includes the relationship id and name.
CREATE TABLE folio_reporting.instance_electronic_access AS
SELECT
    instance.id AS instance_id,
    instance.hrid AS instance_hrid,
    json_extract_path_text(electronic_access.data, 'linkText') AS link_text,
    json_extract_path_text(electronic_access.data, 'materialsSpecification') AS materials_specification,
    json_extract_path_text(electronic_access.data, 'publicNote') AS public_note,
    json_extract_path_text(electronic_access.data, 'relationshipId') AS relationship_id,
    inventory_electronic_access_relationships.name AS relationship_name,
    json_extract_path_text(electronic_access.data, 'uri') AS uri
FROM
    inventory_instances AS instance
    CROSS JOIN json_array_elements(json_extract_path(data, 'electronicAccess')) AS electronic_access(data)
    LEFT JOIN inventory_electronic_access_relationships ON json_extract_path_text(electronic_access.data, 'relationshipId') = inventory_electronic_access_relationships.id;

CREATE INDEX ON folio_reporting.instance_electronic_access (instance_id);

CREATE INDEX ON folio_reporting.instance_electronic_access (instance_hrid);

CREATE INDEX ON folio_reporting.instance_electronic_access (link_text);

CREATE INDEX ON folio_reporting.instance_electronic_access (materials_specification);

CREATE INDEX ON folio_reporting.instance_electronic_access (public_note);

CREATE INDEX ON folio_reporting.instance_electronic_access (relationship_id);

CREATE INDEX ON folio_reporting.instance_electronic_access (relationship_name);

CREATE INDEX ON folio_reporting.instance_electronic_access (uri);

