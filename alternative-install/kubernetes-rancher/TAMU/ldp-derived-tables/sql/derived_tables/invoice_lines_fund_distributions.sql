DROP TABLE IF EXISTS folio_reporting.invoice_lines_fund_distributions;

-- Create a local table for Fund Distributions
CREATE TABLE folio_reporting.invoice_lines_fund_distributions AS
WITH funds_distr AS (
    SELECT
        id AS invoice_line_id,
        json_extract_path_text(dist.data, 'code') AS fund_distribution_code,
        json_extract_path_text(dist.data, 'fundId') AS fund_distribution_id,
        json_extract_path_text(dist.data, 'distributionType') AS fund_distribution_type,
        json_extract_path_text(dist.data, 'value')::numeric AS fund_distribution_value,
        json_extract_path_text(lines.data, 'subTotal')::numeric(12,2) AS invoice_line_sub_total,
        json_extract_path_text(lines.data, 'total')::numeric(12,2) AS invoice_line_total
    FROM
        invoice_lines AS lines
        CROSS JOIN json_array_elements(json_extract_path(data, 'fundDistributions')) AS dist(data)
)
SELECT
    invoice_line_id AS invoice_line_id,
    fund_distribution_id AS fund_distribution_id,
    json_extract_path_text(ff.data, 'fundStatus') AS finance_fund_status,
    json_extract_path_text(ff.data, 'code') AS finance_fund_code,
    json_extract_path_text(ff.data, 'name') AS fund_name,
    json_extract_path_text(ff.data, 'id') AS fund_type_id,
    json_extract_path_text(ft.data, 'name') AS fund_type_name,
    fund_distribution_value AS fund_distribution_value,
    fund_distribution_type AS fund_distribution_type,
    invoice_line_sub_total AS invoice_line_sub_total,
    invoice_line_total AS invoice_line_total
FROM
    funds_distr
    LEFT JOIN finance_funds AS ff ON ff.id = funds_distr.fund_distribution_id
    LEFT JOIN finance_fund_types AS ft ON ft.id = json_extract_path_text(ff.data, 'fundTypeId');

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (invoice_line_id);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (fund_distribution_id);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (finance_fund_status);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (finance_fund_code);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (fund_name);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (fund_type_id);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (fund_type_name);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (fund_distribution_value);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (fund_distribution_type);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (invoice_line_sub_total);

CREATE INDEX ON folio_reporting.invoice_lines_fund_distributions (invoice_line_total);

