-- this query depends on locations_libraries, so that
-- should be run before this one
DROP TABLE IF EXISTS folio_reporting.loans_items;

-- Create a derived table that contains all items from loans and adds
-- item, location, and other loan-related information
--
-- Tables included:
--     circulation_loans
--     inventory_items
--     inventory_material_types
--     circulation_loan_policies
--     user_groups
--     inventory_locations
--     inventory_service_points
--     inventory_loan_types
--     feesfines_overdue_fines_policies
--     feesfines_lost_item_fees_policies
--
-- Location names are from the items table.  They show location of the
-- item right now vs. when item was checked out.
--
CREATE TABLE folio_reporting.loans_items AS
SELECT
    cl.id AS loan_id,
    cl.item_id,
    cl.item_status,
    json_extract_path_text(cl.data, 'status', 'name') AS loan_status,
    cl.loan_date,
    cl.due_date AS loan_due_date,
    cl.return_date AS loan_return_date,
    json_extract_path_text(cl.data, 'systemReturnDate')::timestamptz AS system_return_date,
    json_extract_path_text(cl.data, 'checkinServicePointId') AS checkin_service_point_id,
    ispi.discovery_display_name AS checkin_service_point_name,
    json_extract_path_text(cl.data, 'checkoutServicePointId') AS checkout_service_point_id,
    ispo.discovery_display_name AS checkout_service_point_name,
    json_extract_path_text(cl.data, 'itemEffectiveLocationIdAtCheckOut') AS item_effective_location_id_at_check_out,
    icl.name AS item_effective_location_name_at_check_out,
    json_extract_path_text(ii.data, 'inTransitDestinationServicePointId') AS in_transit_destination_service_point_id,
    ispt.discovery_display_name AS in_transit_destination_service_point_name,
    ii.effective_location_id AS current_item_effective_location_id,
    iel.name AS current_item_effective_location_name,
    json_extract_path_text(ii.data, 'temporaryLocationId') AS current_item_temporary_location_id,
    itl.name AS current_item_temporary_location_name,
    json_extract_path_text(ii.data, 'permanentLocationId') AS current_item_permanent_location_id,
    ipl.name AS current_item_permanent_location_name,
    ll.library_id AS current_item_permanent_location_library_id,
    ll.library_name AS current_item_permanent_location_library_name,
    ll.campus_id AS current_item_permanent_location_campus_id,
    ll.campus_name AS current_item_permanent_location_campus_name,
    ll.institution_id AS current_item_permanent_location_institution_id,
    ll.institution_name AS current_item_permanent_location_institution_name,
    json_extract_path_text(cl.data, 'loanPolicyId') AS loan_policy_id,
    clp.name AS loan_policy_name,
    json_extract_path_text(cl.data, 'lostItemPolicyId') AS lost_item_policy_id,
    ffl.name AS lost_item_policy_name,
    json_extract_path_text(cl.data, 'overdueFinePolicyId') AS overdue_fine_policy_id,
    ffo.name AS overdue_fine_policy_name,
    json_extract_path_text(cl.data, 'patronGroupIdAtCheckout') AS patron_group_id_at_checkout,
    ug.group AS patron_group_name,
    json_extract_path_text(cl.data, 'userId') AS user_id,
    json_extract_path_text(cl.data, 'proxyUserId') AS proxy_user_id,
    ii.barcode,
    json_extract_path_text(ii.data, 'chronology') AS chronology,
    json_extract_path_text(ii.data, 'copyNumber') AS copy_number,
    json_extract_path_text(ii.data, 'enumeration') AS enumeration,
    ii.holdings_record_id,
    ii.hrid,
    json_extract_path_text(ii.data, 'itemLevelCallNumber') AS item_level_call_number,
    ii.material_type_id,
    imt.name AS material_type_name,
    json_extract_path_text(ii.data, 'numberOfPieces') AS number_of_pieces,
    ii.permanent_loan_type_id,
    iltp.name AS permanent_loan_type_name,
    json_extract_path_text(ii.data, 'temporaryLoanTypeId') AS temporary_loan_type_id,
    iltt.name AS temporary_loan_type_name,
    json_extract_path_text(cl.data, 'renewalCount')::bigint AS renewal_count
FROM
    circulation_loans AS cl
    LEFT JOIN inventory_items AS ii ON cl.item_id = ii.id
    LEFT JOIN inventory_material_types AS imt ON ii.material_type_id = imt.id
    LEFT JOIN circulation_loan_policies AS clp ON json_extract_path_text(cl.data, 'loanPolicyId') = clp.id
    LEFT JOIN user_groups AS ug ON json_extract_path_text(cl.data, 'patronGroupIdAtCheckout') = ug.id
    LEFT JOIN inventory_locations AS iel ON ii.effective_location_id = iel.id
    LEFT JOIN inventory_locations AS ipl ON json_extract_path_text(ii.data, 'permanentLocationId') = ipl.id
    LEFT JOIN folio_reporting.locations_libraries AS ll ON ipl.id = ll.location_id
    LEFT JOIN inventory_locations AS itl ON json_extract_path_text(ii.data, 'temporaryLocationId') = itl.id
    LEFT JOIN inventory_locations AS icl ON json_extract_path_text(cl.data, 'itemEffectiveLocationIdAtCheckOut') = icl.id
    LEFT JOIN inventory_service_points AS ispi ON json_extract_path_text(cl.data, 'checkinServicePointId') = ispi.id
    LEFT JOIN inventory_service_points AS ispo ON json_extract_path_text(cl.data, 'checkoutServicePointId') = ispo.id
    LEFT JOIN inventory_service_points AS ispt ON json_extract_path_text(ii.data, 'inTransitDestinationServicePointId') = ispt.id
    LEFT JOIN inventory_loan_types AS iltp ON json_extract_path_text(ii.data, 'temporaryLoanTypeId') = iltp.id
    LEFT JOIN inventory_loan_types AS iltt ON ii.permanent_loan_type_id = iltt.id
    LEFT JOIN feesfines_overdue_fines_policies AS ffo ON json_extract_path_text(cl.data, 'overdueFinePolicyId') = ffo.id
    LEFT JOIN feesfines_lost_item_fees_policies AS ffl ON json_extract_path_text(cl.data, 'lostItemPolicyId') = ffl.id;

CREATE INDEX ON folio_reporting.loans_items (item_status);

CREATE INDEX ON folio_reporting.loans_items (loan_status);

CREATE INDEX ON folio_reporting.loans_items (loan_date);

CREATE INDEX ON folio_reporting.loans_items (loan_due_date);

CREATE INDEX ON folio_reporting.loans_items (current_item_effective_location_name);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_name);

CREATE INDEX ON folio_reporting.loans_items (current_item_temporary_location_name);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_library_name);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_campus_name);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_institution_name);

CREATE INDEX ON folio_reporting.loans_items (checkin_service_point_name);

CREATE INDEX ON folio_reporting.loans_items (checkout_service_point_name);

CREATE INDEX ON folio_reporting.loans_items (in_transit_destination_service_point_name);

CREATE INDEX ON folio_reporting.loans_items (patron_group_name);

CREATE INDEX ON folio_reporting.loans_items (material_type_name);

CREATE INDEX ON folio_reporting.loans_items (permanent_loan_type_name);

CREATE INDEX ON folio_reporting.loans_items (temporary_loan_type_name);

CREATE INDEX ON folio_reporting.loans_items (loan_id);

CREATE INDEX ON folio_reporting.loans_items (item_id);

CREATE INDEX ON folio_reporting.loans_items (loan_return_date);

CREATE INDEX ON folio_reporting.loans_items (system_return_date);

CREATE INDEX ON folio_reporting.loans_items (checkin_service_point_id);

CREATE INDEX ON folio_reporting.loans_items (checkout_service_point_id);

CREATE INDEX ON folio_reporting.loans_items (item_effective_location_id_at_check_out);

CREATE INDEX ON folio_reporting.loans_items (item_effective_location_name_at_check_out);

CREATE INDEX ON folio_reporting.loans_items (in_transit_destination_service_point_id);

CREATE INDEX ON folio_reporting.loans_items (current_item_effective_location_id);

CREATE INDEX ON folio_reporting.loans_items (current_item_temporary_location_id);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_id);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_library_id);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_campus_id);

CREATE INDEX ON folio_reporting.loans_items (current_item_permanent_location_institution_id);

CREATE INDEX ON folio_reporting.loans_items (loan_policy_id);

CREATE INDEX ON folio_reporting.loans_items (loan_policy_name);

CREATE INDEX ON folio_reporting.loans_items (lost_item_policy_id);

CREATE INDEX ON folio_reporting.loans_items (lost_item_policy_name);

CREATE INDEX ON folio_reporting.loans_items (overdue_fine_policy_id);

CREATE INDEX ON folio_reporting.loans_items (overdue_fine_policy_name);

CREATE INDEX ON folio_reporting.loans_items (patron_group_id_at_checkout);

CREATE INDEX ON folio_reporting.loans_items (user_id);

CREATE INDEX ON folio_reporting.loans_items (proxy_user_id);

CREATE INDEX ON folio_reporting.loans_items (barcode);

CREATE INDEX ON folio_reporting.loans_items (chronology);

CREATE INDEX ON folio_reporting.loans_items (copy_number);

CREATE INDEX ON folio_reporting.loans_items (enumeration);

CREATE INDEX ON folio_reporting.loans_items (holdings_record_id);

CREATE INDEX ON folio_reporting.loans_items (hrid);

CREATE INDEX ON folio_reporting.loans_items (item_level_call_number);

CREATE INDEX ON folio_reporting.loans_items (material_type_id);

CREATE INDEX ON folio_reporting.loans_items (number_of_pieces);

CREATE INDEX ON folio_reporting.loans_items (permanent_loan_type_id);

CREATE INDEX ON folio_reporting.loans_items (temporary_loan_type_id);

CREATE INDEX ON folio_reporting.loans_items (renewal_count);
