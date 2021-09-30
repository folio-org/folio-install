DROP TABLE IF EXISTS folio_reporting.item_ext;

-- Create an extended items table that includes the name for in
-- transit destination service point, item damaged status, material
-- type call number type, permanent loan type, permanent location,
-- temporary loan type, temporary location, created_date,
-- description_of_pieces, status_date, status_name, holdings_id
-- Item notes are in a separate derived table.
-- There is a separate table for effective call number. However, it is also included here.
CREATE TABLE folio_reporting.item_ext AS
WITH items AS (
    SELECT
        id,
        hrid,
        json_extract_path_text(data, 'accessionNumber') AS accession_number,
        barcode,
        json_extract_path_text(data, 'chronology') AS chronology,
        json_extract_path_text(data, 'copyNumber') AS copy_number,
        json_extract_path_text(data, 'enumeration') AS enumeration,
        json_extract_path_text(data, 'volume') AS volume,
        json_extract_path_text(data, 'inTransitDestinationServicePointId') AS in_transit_destination_service_point_id,
        json_extract_path_text(data, 'itemIdentifier') AS item_identifier,
        json_extract_path_text(data, 'itemLevelCallNumber') AS item_level_call_number,
        json_extract_path_text(data, 'itemLevelCallNumberTypeId') AS item_level_call_number_type_id,
        json_extract_path_text(data, 'effectiveCallNumberComponents', 'prefix') AS effective_call_number_prefix,
        json_extract_path_text(data, 'effectiveCallNumberComponents', 'callNumber') AS effective_call_number,
        json_extract_path_text(data, 'effectiveCallNumberComponents', 'suffix') AS effective_call_number_suffix,
        json_extract_path_text(data, 'effectiveCallNumberComponents', 'typeID') AS effective_call_number_type_id,
        json_extract_path_text(data, 'itemDamagedStatusId') AS item_damaged_status_id,
        material_type_id,
        json_extract_path_text(data, 'numberOfPieces') AS number_of_pieces,
        json_extract_path_text(data, 'numberOfMissingPieces') AS number_of_missing_pieces,
        json_extract_path_text(data, 'permanentLoanTypeId') AS permanent_loan_type_id,
        json_extract_path_text(data, 'temporaryLoanTypeId') AS temporary_loan_type_id,
        json_extract_path_text(data, 'permanentLocationId') AS permanent_location_id,
        json_extract_path_text(data, 'temporaryLocationId') AS temporary_location_id,
        json_extract_path_text(data, 'effectiveLocationId') AS effective_location_id,
        json_extract_path_text(data, 'metadata', 'createdDate') AS created_date,
        json_extract_path_text(data, 'metadata', 'updatedByUserId') AS updated_by_user_id,
        json_extract_path_text(data, 'metadata', 'updatedDate') AS updated_date,
        json_extract_path_text(data, 'circulationNotes', 'descriptionOfPieces') AS description_of_pieces,
        json_extract_path_text(data, 'status', 'date') AS status_date,
        json_extract_path_text(data, 'status', 'name') AS status_name,
        json_extract_path_text(data, 'holdingsRecordId') AS holdings_record_id,
        json_extract_path_text(data, 'discoverySuppress')::boolean AS discovery_suppress
    FROM
        inventory_items
)
SELECT
    items.id AS item_id,
    items.hrid AS item_hrid,
    items.accession_number,
    items.barcode,
    items.chronology,
    items.copy_number,
    items.enumeration,
    items.volume,
    items.in_transit_destination_service_point_id,
    item_in_transit_destination_service_point.name AS in_transit_destination_service_point_name,
    items.item_identifier AS identifier,
    items.item_level_call_number AS call_number,
    items.item_level_call_number_type_id AS call_number_type_id,
    item_call_number_type.name AS call_number_type_name,
    items.effective_call_number_prefix,
    items.effective_call_number,
    items.effective_call_number_suffix,
    items.effective_call_number_type_id,
    effective_call_number_type.name AS effective_call_number_type_name,
    items.item_damaged_status_id AS damaged_status_id,
    item_damaged_status.name AS damaged_status_name,
    items.material_type_id,
    item_material_type.name AS material_type_name,
    items.number_of_pieces,
    items.number_of_missing_pieces,
    items.permanent_loan_type_id,
    item_permanent_loan_type.name AS permanent_loan_type_name,
    items.temporary_loan_type_id,
    item_temporary_loan_type.name AS temporary_loan_type_name,
    items.permanent_location_id,
    item_permanent_location.name AS permanent_location_name,
    items.temporary_location_id,
    item_temporary_location.name AS temporary_location_name,
    items.effective_location_id,
    item_effective_location.name AS effective_location_name,
    items.description_of_pieces,
    items.status_date,
    items.status_name,
    items.holdings_record_id,
    items.discovery_suppress,
    items.created_date,
    items.updated_by_user_id,
    items.updated_date
FROM
    items
    LEFT JOIN inventory_service_points AS item_in_transit_destination_service_point ON items.in_transit_destination_service_point_id = item_in_transit_destination_service_point.id
    LEFT JOIN inventory_material_types AS item_material_type ON items.material_type_id = item_material_type.id
    LEFT JOIN inventory_loan_types AS item_permanent_loan_type ON items.permanent_loan_type_id = item_permanent_loan_type.id
    LEFT JOIN inventory_loan_types AS item_temporary_loan_type ON items.temporary_loan_type_id = item_temporary_loan_type.id
    LEFT JOIN inventory_locations AS item_permanent_location ON items.permanent_location_id = item_permanent_location.id
    LEFT JOIN inventory_locations AS item_temporary_location ON items.temporary_location_id = item_temporary_location.id
    LEFT JOIN inventory_locations AS item_effective_location ON items.effective_location_id = item_effective_location.id
    LEFT JOIN inventory_item_damaged_statuses AS item_damaged_status ON items.item_damaged_status_id = item_damaged_status.id
    LEFT JOIN inventory_call_number_types AS item_call_number_type ON items.item_level_call_number_type_id = item_call_number_type.id
    LEFT JOIN inventory_call_number_types AS effective_call_number_type ON items.effective_call_number_type_id = effective_call_number_type.id;

CREATE INDEX ON folio_reporting.item_ext (item_id);

CREATE INDEX ON folio_reporting.item_ext (item_hrid);

CREATE INDEX ON folio_reporting.item_ext (accession_number);

CREATE INDEX ON folio_reporting.item_ext (barcode);

CREATE INDEX ON folio_reporting.item_ext (chronology);

CREATE INDEX ON folio_reporting.item_ext (copy_number);

CREATE INDEX ON folio_reporting.item_ext (enumeration);

CREATE INDEX ON folio_reporting.item_ext (volume);

CREATE INDEX ON folio_reporting.item_ext (in_transit_destination_service_point_id);

CREATE INDEX ON folio_reporting.item_ext (in_transit_destination_service_point_name);

CREATE INDEX ON folio_reporting.item_ext (identifier);

CREATE INDEX ON folio_reporting.item_ext (call_number);

CREATE INDEX ON folio_reporting.item_ext (call_number_type_id);

CREATE INDEX ON folio_reporting.item_ext (call_number_type_name);

CREATE INDEX ON folio_reporting.item_ext (effective_call_number_prefix);

CREATE INDEX ON folio_reporting.item_ext (effective_call_number);

CREATE INDEX ON folio_reporting.item_ext (effective_call_number_suffix);

CREATE INDEX ON folio_reporting.item_ext (effective_call_number_type_id);

CREATE INDEX ON folio_reporting.item_ext (effective_call_number_type_name);

CREATE INDEX ON folio_reporting.item_ext (damaged_status_id);

CREATE INDEX ON folio_reporting.item_ext (damaged_status_name);

CREATE INDEX ON folio_reporting.item_ext (material_type_id);

CREATE INDEX ON folio_reporting.item_ext (material_type_name);

CREATE INDEX ON folio_reporting.item_ext (number_of_pieces);

CREATE INDEX ON folio_reporting.item_ext (number_of_missing_pieces);

CREATE INDEX ON folio_reporting.item_ext (permanent_loan_type_id);

CREATE INDEX ON folio_reporting.item_ext (permanent_loan_type_name);

CREATE INDEX ON folio_reporting.item_ext (temporary_loan_type_id);

CREATE INDEX ON folio_reporting.item_ext (temporary_loan_type_name);

CREATE INDEX ON folio_reporting.item_ext (permanent_location_id);

CREATE INDEX ON folio_reporting.item_ext (permanent_location_name);

CREATE INDEX ON folio_reporting.item_ext (temporary_location_id);

CREATE INDEX ON folio_reporting.item_ext (temporary_location_name);

CREATE INDEX ON folio_reporting.item_ext (effective_location_id);

CREATE INDEX ON folio_reporting.item_ext (effective_location_name);

CREATE INDEX ON folio_reporting.item_ext (description_of_pieces);

CREATE INDEX ON folio_reporting.item_ext (status_date);

CREATE INDEX ON folio_reporting.item_ext (status_name);

CREATE INDEX ON folio_reporting.item_ext (holdings_record_id);

CREATE INDEX ON folio_reporting.item_ext (discovery_suppress);

CREATE INDEX ON folio_reporting.item_ext (created_date);

CREATE INDEX ON folio_reporting.item_ext (updated_by_user_id);

CREATE INDEX ON folio_reporting.item_ext (updated_date);

