DROP TABLE IF EXISTS folio_reporting.holdings_electronic_access;

-- Create table for electronic access points for holdings records
CREATE TABLE folio_reporting.holdings_electronic_access AS
SELECT
    holdings.id AS holdings_id,
    holdings.hrid AS holdings_hrid,
    json_extract_path_text(electronic_access.data, 'linkText') AS link_text,
    json_extract_path_text(electronic_access.data, 'materialsSpecification') AS materials_specification,
    json_extract_path_text(electronic_access.data, 'publicNote') AS public_note,
    json_extract_path_text(electronic_access.data, 'relationshipId') AS relationship_id,
    inventory_electronic_access_relationships.name AS relationship_name,
    json_extract_path_text(electronic_access.data, 'uri') AS uri
FROM
    inventory_holdings AS holdings
    CROSS JOIN json_array_elements(json_extract_path(data, 'electronicAccess')) AS electronic_access(data)
    LEFT JOIN inventory_electronic_access_relationships ON json_extract_path_text(electronic_access.data, 'relationshipId') = inventory_electronic_access_relationships.id;

CREATE INDEX ON folio_reporting.holdings_electronic_access (holdings_id);

CREATE INDEX ON folio_reporting.holdings_electronic_access (holdings_hrid);

CREATE INDEX ON folio_reporting.holdings_electronic_access (link_text);

CREATE INDEX ON folio_reporting.holdings_electronic_access (materials_specification);

CREATE INDEX ON folio_reporting.holdings_electronic_access (public_note);

CREATE INDEX ON folio_reporting.holdings_electronic_access (relationship_id);

CREATE INDEX ON folio_reporting.holdings_electronic_access (relationship_name);

CREATE INDEX ON folio_reporting.holdings_electronic_access (uri);

