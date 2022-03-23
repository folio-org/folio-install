DROP TABLE IF EXISTS folio_reporting.invoice_lines_adjustments;

-- This table includes the extracted adjustments data on the invoice
-- line level.  The field description can be locally defined by the
-- institutions.  Examples are "shipping", "VAT" (MwSt), "Service
-- Charge".
CREATE TABLE folio_reporting.invoice_lines_adjustments AS
WITH adjustments AS (
    SELECT
        id AS invoice_line_id,
        json_extract_path_text(adjustments.data, 'description') AS adjustment_description,
        json_extract_path_text(adjustments.data, 'fundDistributions') AS adjustment_fund_distributions,
        json_extract_path_text(adjustments.data, 'prorate') AS adjustment_prorate,
        json_extract_path_text(adjustments.data, 'relationToTotal') AS adjustment_relationToTotal,
        json_extract_path_text(adjustments.data, 'type') AS adjustment_type,
        json_extract_path_text(adjustments.data, 'value') AS adjustment_value,
        json_extract_path_text(invoice_lines.data, 'adjustmentsTotal')::numeric(12,2) AS adjustment_adjustments_total
    FROM
        invoice_lines
        CROSS JOIN json_array_elements(json_extract_path(data, 'adjustments'))
            AS adjustments(data)
)
SELECT
    invoice_line_id,
    adjustment_description,
    adjustment_fund_distributions,
    adjustment_prorate,
    adjustment_relationToTotal,
    adjustment_type,
    adjustment_value,
    adjustment_adjustments_total
FROM
    adjustments
WHERE
    adjustment_relationToTotal = 'In addition to'
    OR adjustment_relationToTotal = 'Included'
    OR adjustment_relationToTotal = 'Separate from';

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (invoice_line_id);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_description);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_fund_distributions);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_prorate);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_relationToTotal);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_type);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_value);

CREATE INDEX ON folio_reporting.invoice_lines_adjustments (adjustment_adjustments_total);

