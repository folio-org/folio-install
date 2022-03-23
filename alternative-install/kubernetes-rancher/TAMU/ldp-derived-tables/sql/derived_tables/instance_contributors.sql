DROP TABLE IF EXISTS folio_reporting.instance_contributors;

-- Create a derived table for contributors from instance records
CREATE TABLE folio_reporting.instance_contributors AS
SELECT
    instance.id AS instance_id,
    instance.hrid AS instance_hrid,
    json_extract_path_text(contributors.data, 'contributorNameTypeId') AS contributor_name_type_id,
    inventory_contributor_name_types.name AS contributor_name_type,
    json_extract_path_text(contributors.data, 'contributorTypeId') AS contributor_rdatype_id,
    inventory_contributor_types.name AS contributor_rdatype_name,
    json_extract_path_text(contributors.data, 'contributorTypeText') AS contributor_type_freetext,
    json_extract_path_text(contributors.data, 'name') AS contributor_name,
    json_extract_path_text(contributors.data, 'primary')::boolean AS contributor_primary
FROM
    inventory_instances AS instance
    CROSS JOIN json_array_elements(json_extract_path(instance.data, 'contributors')) AS contributors(data)
    LEFT JOIN inventory_contributor_name_types ON json_extract_path_text(contributors.data, 'contributorNameTypeId') = inventory_contributor_name_types.id
    LEFT JOIN inventory_contributor_types ON json_extract_path_text(contributors.data, 'contributorTypeId') = inventory_contributor_types.id;

CREATE INDEX ON folio_reporting.instance_contributors (instance_id);

CREATE INDEX ON folio_reporting.instance_contributors (instance_hrid);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_name_type_id);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_name_type);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_rdatype_id);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_rdatype_name);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_type_freetext);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_name);

CREATE INDEX ON folio_reporting.instance_contributors (contributor_primary);

