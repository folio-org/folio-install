/* This derived table pulls renewals from the circulation_loan_history by 
 * filtering on the loan's "action" column. Additional columns allow users to 
 * join renewals with dates to other tables, to filter down to specific renewals, 
 * or to validate the results. */
DROP TABLE IF EXISTS folio_reporting.loans_renewal_dates;

CREATE TABLE folio_reporting.loans_renewal_dates AS
    SELECT
        id AS loan_history_id,
        created_date AS loan_action_date,
        json_extract_path_text(data, 'loan', 'id') AS loan_id,
        json_extract_path_text(data, 'loan', 'itemId') AS item_id,
        json_extract_path_text(data, 'loan', 'action') AS loan_action,
        json_extract_path_text(data, 'loan', 'renewalCount') AS loan_renewal_count,
        json_extract_path_text(data, 'loan', 'status', 'name') AS loan_status
    FROM public.circulation_loan_history
    WHERE
        json_extract_path_text(data, 'loan', 'action') IN ('renewed', 'renewedThroughOverride')
    ORDER BY
        loan_id,
        loan_action_date
;

CREATE INDEX ON folio_reporting.loans_renewal_dates (loan_history_id);

CREATE INDEX ON folio_reporting.loans_renewal_dates (loan_action_date);

CREATE INDEX ON folio_reporting.loans_renewal_dates (loan_id);

CREATE INDEX ON folio_reporting.loans_renewal_dates (item_id);

CREATE INDEX ON folio_reporting.loans_renewal_dates (loan_action);

CREATE INDEX ON folio_reporting.loans_renewal_dates (loan_renewal_count);

CREATE INDEX ON folio_reporting.loans_renewal_dates (loan_status);