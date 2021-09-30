DROP TABLE IF EXISTS folio_reporting.po_lines_physical;

-- Create a local table for Purchase Order Lines Physical material data.
CREATE TABLE folio_reporting.po_lines_physical AS
WITH temp_phys AS (
    SELECT
        pol.id AS pol_id,
        json_extract_path_text(pol.data, 'physical', 'createInventory') AS pol_phys_create_inventory,
        json_extract_path_text(pol.data, 'physical', 'materialType') AS pol_phys_mat_type,
        json_extract_path_text(pol.data, 'physical', 'materialSupplier') AS pol_phys_mat_supplier,
        json_extract_path_text(pol.data, 'physical', 'expectedReceiptDate') AS pol_phys_expected_receipt_date,
        json_extract_path_text(pol.data, 'physical', 'receiptDue') AS pol_phys_receipt_due,
        physical_volumes.data #>> '{}' AS pol_volumes,
        physical_volumes.ordinality AS pol_volumes_ordinality,
        json_extract_path_text(pol.data, 'physical', 'volumes', 'description') AS pol_phys_volumes_description
    FROM
        po_lines AS pol
        CROSS JOIN LATERAL json_array_elements(json_extract_path(data, 'physical', 'volumes'))
        WITH ORDINALITY AS physical_volumes (data)
)
SELECT
    tp.pol_id,
    tp.pol_phys_create_inventory,
    tp.pol_phys_mat_type,
    imt.name AS pol_er_mat_type_name,
    tp.pol_phys_mat_supplier,
    oo.name AS supplier_org_name,
    tp.pol_phys_expected_receipt_date,
    tp.pol_phys_receipt_due,
    tp.pol_volumes,
    tp.pol_volumes_ordinality,
    tp.pol_phys_volumes_description
FROM
    temp_phys AS tp
    LEFT JOIN inventory_material_types AS imt ON imt.id = tp.pol_phys_mat_type
    LEFT JOIN organization_organizations AS oo ON oo.id = tp.pol_phys_mat_supplier;

CREATE INDEX ON folio_reporting.po_lines_physical (pol_id);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_phys_create_inventory);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_phys_mat_type);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_er_mat_type_name);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_phys_mat_supplier);

CREATE INDEX ON folio_reporting.po_lines_physical (supplier_org_name);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_phys_expected_receipt_date);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_phys_receipt_due);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_volumes);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_volumes_ordinality);

CREATE INDEX ON folio_reporting.po_lines_physical (pol_phys_volumes_description);

