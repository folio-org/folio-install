DROP TABLE IF EXISTS folio_reporting.holdings_statements_indexes;

-- This table contains holdings statements for indexes with their
-- associated public/staff only notes; regular holdings statements and
-- holdings statements for supplements are in separate tables. Here note is a public note.
CREATE TABLE folio_reporting.holdings_statements_indexes AS
SELECT
    holdings.id AS holdings_id,
    holdings.hrid AS holdings_hrid,
    json_extract_path_text(holdings_statements_for_indexes.data, 'statement') AS "statement",
    json_extract_path_text(holdings_statements_for_indexes.data, 'note') AS public_note,
    json_extract_path_text(holdings_statements_for_indexes.data, 'staffNote') AS staff_note
FROM
    inventory_holdings AS holdings
    CROSS JOIN json_array_elements(json_extract_path(data, 'holdingsStatementsForIndexes')) AS holdings_statements_for_indexes(data);

CREATE INDEX ON folio_reporting.holdings_statements_indexes (holdings_id);

CREATE INDEX ON folio_reporting.holdings_statements_indexes (holdings_hrid);

CREATE INDEX ON folio_reporting.holdings_statements_indexes ("statement");

CREATE INDEX ON folio_reporting.holdings_statements_indexes (public_note);

CREATE INDEX ON folio_reporting.holdings_statements_indexes (staff_note);

