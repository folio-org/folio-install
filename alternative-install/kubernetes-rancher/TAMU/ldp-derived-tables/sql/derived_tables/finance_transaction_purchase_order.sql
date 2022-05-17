DROP TABLE IF EXISTS folio_reporting.finance_transaction_purchase_order;

-- Create a derived table that joins purchase orders and po_lines fields to transactions for encumbranced cost reports in system currency
--
-- Tables included:
--    finance_transactions
--    finance_funds
--    finance_budget
--    po_lines
--    po_purchase_orders
CREATE TABLE folio_reporting.finance_transaction_purchase_order AS
SELECT
    ft.id AS transaction_id,
    ft.amount AS transaction_amount,
    ft.currency AS transaction_currency,
    json_extract_path_text(ft.data, 'expenseClassId') AS transaction_expense_class_id,
    ft.fiscal_year_id AS transaction_fiscal_year_id,
    ft.from_fund_id AS transaction_from_fund_id,
    ff.name AS transaction_from_fund_name,
    ff.code AS transaction_from_fund_code,
    fb.id AS transaction_from_budget_id,
    fb.name AS transaction_from_budget_name,
    json_extract_path_text(ft.data, 'encumbrance', 'amountAwaitingPayment') AS transaction_encumbrance_amount_awaiting_payment,
    json_extract_path_text(ft.data, 'encumbrance', 'amountExpended') AS transaction_encumbrance_amount_expended,
    json_extract_path_text(ft.data, 'encumbrance', 'initialAmountEncumbered') AS transaction_encumbrance_initial_amount,
    json_extract_path_text(ft.data, 'encumbrance', 'orderType') AS transaction_encumbrance_order_type,
    json_extract_path_text(ft.data, 'encumbrance', 'subscription') AS transaction_encumbrance_subscription,
    json_extract_path_text(ft.data, 'encumbrance', 'sourcePoLineId') AS po_line_id,
    json_extract_path_text(ft.data, 'encumbrance', 'sourcePurchaseOrderId') AS po_id,
    pol.po_line_number AS pol_number,
    json_extract_path_text(pol.data, 'description') AS pol_description,
    pol.acquisition_method AS pol_acquisition_method,
    po.order_type AS po_order_type,
    po.vendor AS po_vendor_id,
    oo.name AS po_vendor_name
FROM
    finance_transactions AS ft
    LEFT JOIN po_lines AS pol ON json_extract_path_text(ft.data, 'encumbrance', 'sourcePoLineId') = pol.id
    LEFT JOIN po_purchase_orders AS po ON json_extract_path_text(ft.data, 'encumbrance', 'sourcePurchaseOrderId') = po.id
    LEFT JOIN finance_funds AS ff ON ft.from_fund_id = ff.id
    LEFT JOIN finance_budgets AS fb ON ft.from_fund_id = fb.fund_id AND ft.fiscal_year_id = fb.fiscal_year_id
    LEFT JOIN organization_organizations AS oo ON po.vendor = oo.id
WHERE
    ft.transaction_type = 'Encumbrance';

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_amount);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_currency);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_expense_class_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_fiscal_year_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_from_fund_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_from_fund_name);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_from_fund_code);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_from_budget_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_from_budget_name);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_encumbrance_amount_awaiting_payment);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_encumbrance_amount_expended);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_encumbrance_initial_amount);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_encumbrance_order_type);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (transaction_encumbrance_subscription);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (po_line_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (po_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (pol_number);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (pol_description);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (pol_acquisition_method);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (po_order_type);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (po_vendor_id);

CREATE INDEX ON folio_reporting.finance_transaction_purchase_order (po_vendor_name);

