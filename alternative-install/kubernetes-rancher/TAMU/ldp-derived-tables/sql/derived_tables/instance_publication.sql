DROP TABLE IF EXISTS folio_reporting.instance_publication;

-- Create table for publication information that includes publication date, place, and publisher name from instance records
CREATE TABLE folio_reporting.instance_publication AS
SELECT
    instance.id AS instance_id,
    instance.hrid AS instance_hrid,
    json_extract_path_text(publication.data, 'dateOfPublication') AS date_of_publication,
    json_extract_path_text(publication.data, 'place') AS place,
    json_extract_path_text(publication.data, 'publisher') AS publisher
FROM
    inventory_instances AS instance
    CROSS JOIN json_array_elements(json_extract_path(instance.data, 'publication')) AS publication(data);

CREATE INDEX ON folio_reporting.instance_publication (instance_id);

CREATE INDEX ON folio_reporting.instance_publication (instance_hrid);

CREATE INDEX ON folio_reporting.instance_publication (date_of_publication);

CREATE INDEX ON folio_reporting.instance_publication (place);

CREATE INDEX ON folio_reporting.instance_publication (publisher);

