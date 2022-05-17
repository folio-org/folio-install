DROP TABLE IF EXISTS folio_reporting.invoice_voucher_lines_fund_distributions;
-- Create a derived table to extract fund_distributions from invoice_voucher_lines and joining funds related tables
CREATE TABLE folio_reporting.invoice_voucher_lines_fund_distributions AS

WITH funds_distr AS (
	SELECT
    	id AS invoice_voucher_line_id,
        json_extract_path_text(dist.data, 'code') AS fund_distribution_code,
        json_extract_path_text(dist.data, 'fundId') AS fund_distribution_id,
        json_extract_path_text(dist.data, 'invoiceLineId') AS fund_distribution_invl_id,
        json_extract_path_text(dist.data, 'expenseClassId') AS fund_distribution_expense_class_id,
        json_extract_path_text(dist.data, 'value') AS fund_distribution_value,
        amount AS invoice_voucher_lines_amount,
        json_extract_path_text(dist.data, 'distributionType') AS fund_distribution_type,
        external_account_number AS invoice_voucher_lines_external_account_number,
        voucher_id AS voucher_id
    FROM
        invoice_voucher_lines AS invvl
        CROSS JOIN json_array_elements(json_extract_path(data, 'fundDistributions')) AS dist(data)
)
SELECT
	invoice_voucher_line_id AS invoice_voucher_line_id,
    voucher_id AS voucher_id,
    invv.voucher_number AS voucher_number,
    invoice_voucher_lines_amount AS invoice_voucher_lines_amount,
    fund_distribution_type AS fund_distribution_type,
    fund_distribution_id AS fund_distribution_id,
    fund_distribution_code AS fund_distribution_code,
    ff.name AS fund_name,
    fund_distribution_invl_id AS fund_distribution_invl_id,
    fund_distribution_expense_class_id AS fund_distribution_expense_class_id,
    fec.name AS expense_class_name,
    fund_distribution_value AS fund_distribution_value,
    ff.fund_status AS fund_status,
--    ff.fund_type_id AS fund_type_id,
    ft.name AS fund_type_name,
    --ff.tags,  Take out '--' when tags are available to add to this query
    invoice_voucher_lines_external_account_number AS invoice_voucher_lines_external_account_number   
FROM
    funds_distr
    LEFT JOIN finance_funds AS ff ON ff.id = funds_distr.fund_distribution_id
    LEFT JOIN finance_fund_types AS ft ON ft.id = json_extract_path_text(ff.data, 'fundTypeId')
    LEFT JOIN finance_expense_classes AS fec ON fec.id = fund_distribution_expense_class_id
    LEFT JOIN invoice_vouchers AS invv ON invv. id = funds_distr.voucher_id
ORDER BY voucher_number;
   
CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (invoice_voucher_line_id);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (voucher_id);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (voucher_number);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (invoice_voucher_lines_amount);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_distribution_type);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_distribution_id);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_distribution_code);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_name);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_distribution_invl_id);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_distribution_expense_class_id);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (expense_class_name);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_distribution_value);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_status);

--CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_type_id);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (fund_type_name);

CREATE INDEX ON folio_reporting.invoice_voucher_lines_fund_distributions (invoice_voucher_lines_external_account_number);

