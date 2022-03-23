DROP TABLE IF EXISTS folio_reporting.requests_items;

-- Create a derived table that contains all items from requests and adds
-- item and patron-related information
CREATE TABLE folio_reporting.requests_items AS
SELECT
    cr.id AS request_id,
    json_extract_path_text(cr.data, 'itemId') AS item_id,
    json_extract_path_text(cr.data, 'requestDate') AS request_date,
    json_extract_path_text(cr.data, 'requestType') AS request_type,
    json_extract_path_text(cr.data, 'status') AS request_status,
    json_extract_path_text(cr.data, 'pickupServicePointId') AS pickup_service_point_id,
    psp.name AS pickup_service_point_name,
    psp.discovery_display_name AS pickup_service_point_disc_disp_name,
    --    ii.in_transit_dest_serv_point_id,
    json_extract_path_text(ii.data, 'inTransitDestinationServicePointId') AS in_transit_dest_serv_point_id,
    isp.name AS in_transit_dest_serv_point_name,
    isp.discovery_display_name AS in_transit_dest_serv_point_disc_disp_name,
    json_extract_path_text(cr.data, 'fulfilmentPreference') AS fulfillment_preference,
    json_extract_path_text(cr.data, 'requesterId') AS requester_id,
    uu.patron_group AS patron_group_id,
    ug.desc AS patron_group_name,
    json_extract_path_text(ii.data, 'itemLevelCallNumber') AS item_level_call_number,
    ii.barcode,
    json_extract_path_text(ii.data, 'chronology') AS chronology,
    json_extract_path_text(ii.data, 'copyNumber') AS item_copy_number,
    ii.effective_location_id AS item_effective_location_id,
    iel.name AS item_effective_location_name,
    json_extract_path_text(ii.data, 'permanentLocationId') AS item_permanent_location_id,
    ipl.name AS item_permanent_location_name,
    json_extract_path_text(ii.data, 'temporaryLocationId') AS item_temporary_location_id,
    itl.name AS item_temporary_location_name,
    json_extract_path_text(ii.data, 'enumeration') AS enumeration,
    ii.holdings_record_id,
    ii.hrid,
    json_extract_path_text(ii.data, 'itemIdentifier') AS item_identifier,
    ii.material_type_id,
    imt.name AS material_type_name,
    json_extract_path_text(ii.data, 'numberOfPieces') AS number_of_pieces,
    ii.permanent_loan_type_id AS item_permanent_loan_type_id,
    iplt.name AS item_permanent_loan_type_name,
    json_extract_path_text(ii.data, 'temporaryLoanTypeId') AS item_temporary_loan_type_id,
    itlt.name AS item_temporary_loan_type_name
FROM
    public.circulation_requests AS cr
    LEFT JOIN public.inventory_items AS ii ON json_extract_path_text(cr.data, 'itemId') = ii.id
    LEFT JOIN public.inventory_service_points AS isp ON json_extract_path_text(ii.data, 'inTransitDestinationServicePointId') = isp.id
    LEFT JOIN public.inventory_service_points AS psp ON json_extract_path_text(cr.data, 'pickupServicePointId') = psp.id
    LEFT JOIN user_users AS uu ON json_extract_path_text(cr.data, 'requesterId') = uu.id
    LEFT JOIN user_groups AS ug ON uu.patron_group = ug.id
    LEFT JOIN inventory_locations AS iel ON ii.effective_location_id = iel.id
    LEFT JOIN inventory_locations AS ipl ON json_extract_path_text(ii.data, 'permanentLocationId') = ipl.id
    LEFT JOIN inventory_locations AS itl ON json_extract_path_text(ii.data, 'temporaryLocationId') = itl.id
    LEFT JOIN inventory_loan_types AS iplt ON ii.permanent_loan_type_id = iplt.id
    LEFT JOIN inventory_loan_types AS itlt ON json_extract_path_text(ii.data, 'temporaryLoanTypeId') = itlt.id
    LEFT JOIN inventory_material_types AS imt ON ii.material_type_id = imt.id;

CREATE INDEX ON folio_reporting.requests_items (request_id);

CREATE INDEX ON folio_reporting.requests_items (item_id);

CREATE INDEX ON folio_reporting.requests_items (request_date);

CREATE INDEX ON folio_reporting.requests_items (request_type);

CREATE INDEX ON folio_reporting.requests_items (request_status);

CREATE INDEX ON folio_reporting.requests_items (pickup_service_point_id);

CREATE INDEX ON folio_reporting.requests_items (pickup_service_point_name);

CREATE INDEX ON folio_reporting.requests_items (pickup_service_point_disc_disp_name);

CREATE INDEX ON folio_reporting.requests_items (in_transit_dest_serv_point_id);

CREATE INDEX ON folio_reporting.requests_items (in_transit_dest_serv_point_name);

CREATE INDEX ON folio_reporting.requests_items (in_transit_dest_serv_point_disc_disp_name);

CREATE INDEX ON folio_reporting.requests_items (fulfillment_preference);

CREATE INDEX ON folio_reporting.requests_items (requester_id);

CREATE INDEX ON folio_reporting.requests_items (patron_group_id);

CREATE INDEX ON folio_reporting.requests_items (patron_group_name);

CREATE INDEX ON folio_reporting.requests_items (item_level_call_number);

CREATE INDEX ON folio_reporting.requests_items (barcode);

CREATE INDEX ON folio_reporting.requests_items (chronology);

CREATE INDEX ON folio_reporting.requests_items (item_copy_number);

CREATE INDEX ON folio_reporting.requests_items (item_effective_location_id);

CREATE INDEX ON folio_reporting.requests_items (item_effective_location_name);

CREATE INDEX ON folio_reporting.requests_items (item_permanent_location_id);

CREATE INDEX ON folio_reporting.requests_items (item_permanent_location_name);

CREATE INDEX ON folio_reporting.requests_items (item_temporary_location_id);

CREATE INDEX ON folio_reporting.requests_items (item_temporary_location_name);

CREATE INDEX ON folio_reporting.requests_items (enumeration);

CREATE INDEX ON folio_reporting.requests_items (holdings_record_id);

CREATE INDEX ON folio_reporting.requests_items (hrid);

CREATE INDEX ON folio_reporting.requests_items (item_identifier);

CREATE INDEX ON folio_reporting.requests_items (material_type_id);

CREATE INDEX ON folio_reporting.requests_items (material_type_name);

CREATE INDEX ON folio_reporting.requests_items (number_of_pieces);

CREATE INDEX ON folio_reporting.requests_items (item_permanent_loan_type_id);

CREATE INDEX ON folio_reporting.requests_items (item_permanent_loan_type_name);

CREATE INDEX ON folio_reporting.requests_items (item_temporary_loan_type_id);

CREATE INDEX ON folio_reporting.requests_items (item_temporary_loan_type_name);

