DROP TABLE IF EXISTS folio_reporting.po_lines_phys_mat_type;

CREATE TABLE folio_reporting.po_lines_phys_mat_type AS
/* Subquery to extract nested JSON data */
WITH temp_pol_phys_mat_type AS (
    SELECT
        pol.id AS pol_id,
        json_extract_path_text(data, 'physical', 'materialType') AS pol_phys_mat_type
    FROM
        po_lines AS pol)
    /* Main query */
    SELECT
        tppmt.pol_id,
        tppmt.pol_phys_mat_type AS pol_phys_mat_type_id,
        imt.name AS pol_mat_type_name
    FROM
        temp_pol_phys_mat_type AS tppmt
    LEFT JOIN inventory_material_types AS imt ON imt.id = tppmt.pol_phys_mat_type;

CREATE INDEX ON folio_reporting.po_lines_phys_mat_type (pol_id);

CREATE INDEX ON folio_reporting.po_lines_phys_mat_type (pol_phys_mat_type_id);

CREATE INDEX ON folio_reporting.po_lines_phys_mat_type (pol_mat_type_name);

