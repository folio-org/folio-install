DROP TABLE IF EXISTS folio_reporting.po_lines_eresource;

-- Create a local table for Purchase Order Line Eresource data.
CREATE TABLE folio_reporting.po_lines_eresource AS
WITH temp_eresource AS (
    SELECT
        pol.id AS pol_id,
        json_extract_path_text(data, 'eresource', 'locationId') AS pol_location_id,
        json_extract_path_text(data, 'eresource', 'accessProvider') AS access_provider,
        json_extract_path_text(data, 'eresource', 'activated') AS pol_activated,
        json_extract_path_text(data, 'eresource', 'activationDue') AS pol_activation_due,
        json_extract_path_text(data, 'eresource', 'createInventory') AS pol_create_inventory,
        json_extract_path_text(data, 'eresource', 'expectedActivation') AS pol_expected_activation,
        json_extract_path_text(data, 'eresource', 'license') AS pol_license,
        json_extract_path_text(data, 'eresource', 'license', 'description') AS pol_license_desc,
        json_extract_path_text(data, 'eresource', 'materialType') AS pol_material_type,
        json_extract_path_text(data, 'eresource', 'trial') AS pol_trial,
        json_extract_path_text(data, 'eresource', 'userLimit') AS pol_user_limit,
        json_extract_path_text(data, 'eresource', 'resourceUrl') AS pol_resource_url
    FROM
        po_lines AS pol
)
SELECT
    te.pol_id,
    te.pol_location_id,
    il.name AS location_name,
    te. access_provider AS pol_access_provider,
    oo.name AS provider_org_name,
    te.pol_activated,
    te.pol_activation_due,
    te.pol_create_inventory,
    te.pol_expected_activation,
    te.pol_license,
    te.pol_license_desc,
    te.pol_material_type,
    imt.name AS pol_er_mat_type_name,
    te.pol_trial,
    te.pol_user_limit,
    te.pol_resource_url
FROM
    temp_eresource AS te
    LEFT JOIN inventory_material_types AS imt ON imt.id = te.pol_material_type
    LEFT JOIN inventory_locations AS il ON il.id = te.pol_location_id
    LEFT JOIN organization_organizations AS oo ON oo.id = te.access_provider;

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_id);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_location_id);

CREATE INDEX ON folio_reporting.po_lines_eresource (location_name);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_access_provider);

CREATE INDEX ON folio_reporting.po_lines_eresource (provider_org_name);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_activated);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_activation_due);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_create_inventory);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_expected_activation);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_license);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_license_desc);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_material_type);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_er_mat_type_name);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_trial);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_user_limit);

CREATE INDEX ON folio_reporting.po_lines_eresource (pol_resource_url);

