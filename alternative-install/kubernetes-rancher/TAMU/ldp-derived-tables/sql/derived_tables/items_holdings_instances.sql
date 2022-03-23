DROP TABLE IF EXISTS folio_reporting.items_holdings_instances;

-- Create an extended items table that includes holdings and instances
-- information such as call number, material type, title, etc.
--
-- Tables included:
--     inventory_items
--     inventory_holdings
--     inventory_instances
--     inventory_loan_types
--     inventory_material_types
--     inventory_holdings_types
--     inventory_call_number_types
--
CREATE TABLE folio_reporting.items_holdings_instances AS
SELECT
    ii.id AS item_id,
    ii.barcode,
    json_extract_path_text(ii.data, 'chronology') AS chronology,
    json_extract_path_text(ii.data, 'copyNumber') AS item_copy_number,
    json_extract_path_text(ii.data, 'enumeration') AS enumeration,
    ii.holdings_record_id,
    ii.hrid,
    json_extract_path_text(ii.data, 'itemIdentifier') AS item_identifier,
    json_extract_path_text(ii.data, 'itemLevelCallNumber') AS item_level_call_number,
    ih.call_number_type_id,
    icnt.name AS call_number_type_name,
    ii.material_type_id,
    imt.name AS material_type_name,
    json_extract_path_text(ii.data, 'numberOfPieces') AS number_of_pieces,
    ih.id AS holdings_id,
    ih.call_number,
    json_extract_path_text(ih.data, 'acquisitionMethod') AS acquisition_method,
    json_extract_path_text(ih.data, 'copyNumber') AS holdings_copy_number,
    json_extract_path_text(ih.data, 'holdingsTypeId') AS holdings_type_id,
    iht.name AS holdings_type_name,
    ih.instance_id,
    json_extract_path_text(ih.data, 'shelvingTitle') AS shelving_title,
    json_extract_path_text(ii2.data, 'catalogedDate') AS cataloged_date,
    ii2.index_title,
    ii2.title,
    ilt.id AS loan_type_id,
    ilt.name AS loan_type_name
FROM
    inventory_items ii
    LEFT JOIN inventory_holdings AS ih ON ii.holdings_record_id = ih.id
    LEFT JOIN inventory_instances AS ii2 ON ih.instance_id = ii2.id
    LEFT JOIN inventory_loan_types AS ilt ON ii.permanent_loan_type_id = ilt.id
    LEFT JOIN inventory_material_types AS imt ON ii.material_type_id = imt.id
    LEFT JOIN inventory_holdings_types AS iht ON json_extract_path_text(ih.data, 'holdingsTypeId') = iht.id
    LEFT JOIN inventory_call_number_types AS icnt ON ih.call_number_type_id = icnt.id;

CREATE INDEX ON folio_reporting.items_holdings_instances (item_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (barcode);

CREATE INDEX ON folio_reporting.items_holdings_instances (chronology);

CREATE INDEX ON folio_reporting.items_holdings_instances (item_copy_number);

CREATE INDEX ON folio_reporting.items_holdings_instances (enumeration);

CREATE INDEX ON folio_reporting.items_holdings_instances (holdings_record_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (hrid);

CREATE INDEX ON folio_reporting.items_holdings_instances (item_identifier);

CREATE INDEX ON folio_reporting.items_holdings_instances (item_level_call_number);

CREATE INDEX ON folio_reporting.items_holdings_instances (call_number_type_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (call_number_type_name);

CREATE INDEX ON folio_reporting.items_holdings_instances (material_type_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (material_type_name);

CREATE INDEX ON folio_reporting.items_holdings_instances (number_of_pieces);

CREATE INDEX ON folio_reporting.items_holdings_instances (holdings_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (call_number);

CREATE INDEX ON folio_reporting.items_holdings_instances (acquisition_method);

CREATE INDEX ON folio_reporting.items_holdings_instances (holdings_copy_number);

CREATE INDEX ON folio_reporting.items_holdings_instances (holdings_type_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (holdings_type_name);

CREATE INDEX ON folio_reporting.items_holdings_instances (instance_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (shelving_title);

CREATE INDEX ON folio_reporting.items_holdings_instances (cataloged_date);

CREATE INDEX ON folio_reporting.items_holdings_instances (index_title);

CREATE INDEX ON folio_reporting.items_holdings_instances (title);

CREATE INDEX ON folio_reporting.items_holdings_instances (loan_type_id);

CREATE INDEX ON folio_reporting.items_holdings_instances (loan_type_name);

