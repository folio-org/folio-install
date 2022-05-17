DROP TABLE IF EXISTS folio_reporting.holdings_statements_supplements;

-- This table contains holdings statements for supplements with their
-- associated public/staff only notes; regular holdings statements and
-- holdings statements for indexes are in separate tables. Here note is a public note.
CREATE TABLE folio_reporting.holdings_statements_supplements AS
SELECT
    holdings.id AS holdings_id,
    holdings.hrid AS holdings_hrid,
    json_extract_path_text(holdings_statements_for_supplements.data, 'statement') AS "statement",
    json_extract_path_text(holdings_statements_for_supplements.data, 'note') AS public_note,
    json_extract_path_text(holdings_statements_for_supplements.data, 'staffNote') AS staff_note
FROM
    inventory_holdings AS holdings
    CROSS JOIN json_array_elements(json_extract_path(data, 'holdingsStatementsForSupplements')) AS holdings_statements_for_supplements(data);

CREATE INDEX ON folio_reporting.holdings_statements_supplements (holdings_id);

CREATE INDEX ON folio_reporting.holdings_statements_supplements (holdings_hrid);

CREATE INDEX ON folio_reporting.holdings_statements_supplements ("statement");

CREATE INDEX ON folio_reporting.holdings_statements_supplements (public_note);

CREATE INDEX ON folio_reporting.holdings_statements_supplements (staff_note);

