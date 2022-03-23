DROP TABLE IF EXISTS folio_reporting.po_lines_locations;

-- Create a local table for Purchase Order Line Locations including location quantity and type.
CREATE TABLE folio_reporting.po_lines_locations AS
WITH pol_location AS (
    SELECT
        pol.id AS pol_id,
        json_extract_path_text(locations.data, 'locationId') AS pol_loc_id,
        json_extract_path_text(locations.data, 'quantity') AS pol_loc_qty,
        json_extract_path_text(locations.data, 'quantityElectronic') AS pol_loc_qty_elec,
        json_extract_path_text(locations.data, 'quantityPhysical') AS pol_loc_quant_phys
    FROM
        po_lines AS pol
        CROSS JOIN json_array_elements(json_extract_path(data, 'locations')) AS locations (data)
)
SELECT
    pol_location.pol_id,
    pol_location.pol_loc_id,
    pol_location.pol_loc_qty,
    pol_location.pol_loc_qty_elec,
    pol_location.pol_loc_quant_phys,
    inventory_locations.name AS location_name
FROM
    pol_location
    LEFT JOIN inventory_locations ON inventory_locations.id = pol_location.pol_loc_id;

CREATE INDEX ON folio_reporting.po_lines_locations (pol_id);

CREATE INDEX ON folio_reporting.po_lines_locations (pol_loc_id);

CREATE INDEX ON folio_reporting.po_lines_locations (pol_loc_qty);

CREATE INDEX ON folio_reporting.po_lines_locations (pol_loc_qty_elec);

CREATE INDEX ON folio_reporting.po_lines_locations (pol_loc_quant_phys);

CREATE INDEX ON folio_reporting.po_lines_locations (location_name);

