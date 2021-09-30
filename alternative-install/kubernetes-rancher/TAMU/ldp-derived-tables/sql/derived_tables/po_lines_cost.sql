DROP TABLE IF EXISTS folio_reporting.po_lines_cost;

-- Create table for cost information on the purchase order line
CREATE TABLE folio_reporting.po_lines_cost AS
SELECT
    pol.id AS pol_id,
    json_extract_path_text(pol.data, 'cost', 'listUnitPrice') AS po_lines_list_unit_price_phys,
    json_extract_path_text(pol.data, 'cost', 'quantityPhysical') AS po_lines_quant_phys,
    json_extract_path_text(pol.data, 'cost', 'listUnitPriceElectronic') AS po_lines_list_unit_price_elec,
    json_extract_path_text(pol.data, 'cost', 'quantityElectronic') AS po_lines_quant_elec,
    json_extract_path_text(pol.data, 'cost', 'additionalCost') AS po_lines_additional_cost,
    json_extract_path_text(pol.data, 'cost', 'currency') AS po_lines_currency,
    json_extract_path_text(pol.data, 'cost', 'discount') AS po_lines_discount,
    json_extract_path_text(pol.data, 'cost', 'discountType') AS po_lines_discount_type,
    json_extract_path_text(pol.data, 'cost', 'poLineEstimatedPrice') AS po_lines_estimated_price
FROM
    po_lines AS pol;

CREATE INDEX ON folio_reporting.po_lines_cost (pol_id);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_list_unit_price_phys);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_quant_phys);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_list_unit_price_elec);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_quant_elec);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_additional_cost);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_currency);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_discount);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_discount_type);

CREATE INDEX ON folio_reporting.po_lines_cost (po_lines_estimated_price);

