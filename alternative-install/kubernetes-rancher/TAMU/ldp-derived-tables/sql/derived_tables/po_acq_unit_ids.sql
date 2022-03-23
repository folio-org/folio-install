DROP TABLE IF EXISTS folio_reporting.po_acq_unit_ids;

-- These fields in adjustments can be locally defined
CREATE TABLE folio_reporting.po_acq_unit_ids AS
WITH po_acq_unit AS (
    SELECT
        id AS po_id,
        json_extract_path_text(po_purchase_orders.data, 'poNumber') AS po_number,
	acq_unit_ids.data #>> '{}' AS po_acq_unit_id
    FROM
        po_purchase_orders
        CROSS JOIN json_array_elements(json_extract_path(data, 'acqUnitIds')) AS acq_unit_ids (data)
)
SELECT
    po_acq_unit.po_id AS po_id,
    po_acq_unit.po_number,
    po_acq_unit.po_acq_unit_id AS po_acquisition_unit_id,
    json_extract_path_text (
        acquisitions_units.data,
        'name'
) AS po_acquisition_unit_name
FROM
    po_acq_unit
    LEFT JOIN acquisitions_units ON acquisitions_units.id = po_acq_unit.po_acq_unit_id;

CREATE INDEX ON folio_reporting.po_acq_unit_ids (po_id);

CREATE INDEX ON folio_reporting.po_acq_unit_ids (po_number);

CREATE INDEX ON folio_reporting.po_acq_unit_ids (po_acquisition_unit_id);

CREATE INDEX ON folio_reporting.po_acq_unit_ids (po_acquisition_unit_name);

