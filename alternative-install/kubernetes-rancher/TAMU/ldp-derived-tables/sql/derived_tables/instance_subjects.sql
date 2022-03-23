DROP TABLE IF EXISTS folio_reporting.instance_subjects;

-- Create a local table for subjects in the instance record.
CREATE TABLE folio_reporting.instance_subjects AS
SELECT
    instances.id AS instance_id,
    instances.hrid AS instance_hrid,
    subjects.data #>> '{}' AS subject,
    subjects.ordinality AS subject_ordinality
FROM
    inventory_instances AS instances
    CROSS JOIN LATERAL json_array_elements(json_extract_path(data, 'subjects'))
    WITH ORDINALITY AS subjects (data);

CREATE INDEX ON folio_reporting.instance_subjects (instance_id);

CREATE INDEX ON folio_reporting.instance_subjects (instance_hrid);

CREATE INDEX ON folio_reporting.instance_subjects (subject);

CREATE INDEX ON folio_reporting.instance_subjects (subject_ordinality);

