DROP TABLE IF EXISTS folio_reporting.holdings_statistical_codes;

-- Create a local holdings table with the id and name for the code and type.
CREATE TABLE folio_reporting.holdings_statistical_codes AS
WITH holdings_statistical_codes AS (
    SELECT
        holdings.id AS holdings_id,
        holdings.hrid AS holdings_hrid,
        statistical_code_ids.data #>> '{}' AS statistical_code_id
    FROM
        inventory_holdings AS holdings
        CROSS JOIN json_array_elements(json_extract_path(data, 'statisticalCodeIds')) AS statistical_code_ids (data)
)
SELECT
    holdings_statistical_codes.holdings_id,
    holdings_statistical_codes.holdings_hrid,
    holdings_statistical_codes.statistical_code_id,
    inventory_statistical_codes.code AS statistical_code,
    inventory_statistical_codes.name AS statistical_code_name,
    inventory_statistical_code_types.id AS statistical_code_type_id,
    inventory_statistical_code_types.name AS statistical_code_type_name
FROM
    holdings_statistical_codes
    LEFT JOIN inventory_statistical_codes ON holdings_statistical_codes.statistical_code_id = inventory_statistical_codes.id
    LEFT JOIN inventory_statistical_code_types ON inventory_statistical_codes.statistical_code_type_id = inventory_statistical_code_types.id;

CREATE INDEX ON folio_reporting.holdings_statistical_codes (holdings_id);

CREATE INDEX ON folio_reporting.holdings_statistical_codes (holdings_hrid);

CREATE INDEX ON folio_reporting.holdings_statistical_codes (statistical_code_id);

CREATE INDEX ON folio_reporting.holdings_statistical_codes (statistical_code);

CREATE INDEX ON folio_reporting.holdings_statistical_codes (statistical_code_name);

CREATE INDEX ON folio_reporting.holdings_statistical_codes (statistical_code_type_id);

CREATE INDEX ON folio_reporting.holdings_statistical_codes (statistical_code_type_name);

