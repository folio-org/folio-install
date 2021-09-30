DROP TABLE IF EXISTS folio_reporting.instance_series;

-- Create a local table for series statemnts in the instance records.
CREATE TABLE folio_reporting.instance_series AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    series.data #>> '{}' AS series,
    series.ordinality AS series_ordinality
FROM
    inventory_instances AS instances
    CROSS JOIN LATERAL json_array_elements(json_extract_path(data, 'series'))
    WITH ORDINALITY AS series (data);

CREATE INDEX ON folio_reporting.instance_series (instance_id);

CREATE INDEX ON folio_reporting.instance_series (instance_hrid);

CREATE INDEX ON folio_reporting.instance_series (series);

CREATE INDEX ON folio_reporting.instance_series (series_ordinality);

