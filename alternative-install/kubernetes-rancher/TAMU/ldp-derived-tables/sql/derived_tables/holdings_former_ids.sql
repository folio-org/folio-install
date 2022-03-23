DROP TABLE IF EXISTS folio_reporting.holdings_former_ids;
DROP TABLE IF EXISTS mis.holdings_former_ids;

CREATE TABLE mis.holdings_former_ids AS
SELECT
    ih.id AS holding_id,
    ih.hrid AS holding_hrid,
    json_array_elements_text(json_extract_path(ih.data, 'formerIds'))::varchar AS former_holding_ids,
    ih.permanent_location_id,
    locations.name AS permanent_location_name,
    libraries.name AS library_name,
    libraries.code AS library_code
FROM
    inventory_holdings AS ih
    LEFT JOIN inventory_locations AS locations ON ih.permanent_location_id = locations.id
    LEFT JOIN inventory_libraries AS libraries ON locations.library_id =libraries.id;

CREATE INDEX ON mis.holdings_former_ids (holding_id);

CREATE INDEX ON mis.holdings_former_ids (holding_hrid);

CREATE INDEX ON mis.holdings_former_ids (former_holding_ids);

CREATE INDEX ON mis.holdings_former_ids (permanent_location_id);

CREATE INDEX ON mis.holdings_former_ids (permanent_location_name);

CREATE INDEX ON mis.holdings_former_ids (library_name);

CREATE INDEX ON mis.holdings_former_ids (library_code);