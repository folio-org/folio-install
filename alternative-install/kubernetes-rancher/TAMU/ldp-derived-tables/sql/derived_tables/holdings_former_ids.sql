DROP TABLE IF EXISTS folio_reporting.holdings_former_ids;

CREATE TABLE folio_reporting.holdings_former_ids AS
SELECT
    holdings.id AS holding_id,
    holdings.hrid AS holding_hrid,
    json_array_elements_text(json_extract_path(holdings.data, 'formerIds'))::varchar AS former_holding_ids
FROM
    inventory_holdings AS holdings;

CREATE INDEX ON folio_reporting.holdings_former_ids (holding_id);

CREATE INDEX ON folio_reporting.holdings_former_ids (holding_hrid);

CREATE INDEX ON folio_reporting.holdings_former_ids (former_holding_ids);
