DROP TABLE IF EXISTS folio_reporting.invoice_adjustments_in_addition_to;

-- This query will return the invoice adjustments when they are "Not Prorated" and "In addition To"
CREATE TABLE folio_reporting.invoice_adjustments_in_addition_to AS
WITH adjustments AS (
    SELECT
        id AS invoice_id,
        json_extract_path_text(adjustments.data, 'description') AS adjustment_description,
        json_extract_path_text(adjustments.data, 'prorate') AS adjustment_prorate,
        json_extract_path_text(adjustments.data, 'relationToTotal') AS adjustment_relationToTotal,
        json_extract_path_text(adjustments.data, 'type') AS adjustment_type,
        json_extract_path_text(adjustments.data, 'value') ::numeric(12,2) AS adjustment_value
    FROM
        invoice_invoices AS inv
        CROSS JOIN json_array_elements(json_extract_path(data, 'adjustments')) AS adjustments (data)
)
SELECT
    invoice_id,
    adjustment_description,
    adjustment_prorate,
    adjustment_relationToTotal,
    adjustment_type,
    adjustment_value
FROM
    adjustments
WHERE
    adjustment_relationToTotal = 'In addition to'
    AND adjustment_prorate = 'Not prorated';

CREATE INDEX ON folio_reporting.invoice_adjustments_in_addition_to (invoice_id);

CREATE INDEX ON folio_reporting.invoice_adjustments_in_addition_to (adjustment_description);

CREATE INDEX ON folio_reporting.invoice_adjustments_in_addition_to (adjustment_prorate);

CREATE INDEX ON folio_reporting.invoice_adjustments_in_addition_to (adjustment_relationToTotal);

CREATE INDEX ON folio_reporting.invoice_adjustments_in_addition_to (adjustment_type);

CREATE INDEX ON folio_reporting.invoice_adjustments_in_addition_to (adjustment_value);

