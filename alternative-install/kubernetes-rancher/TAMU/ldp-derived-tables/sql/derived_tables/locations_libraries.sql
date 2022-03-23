DROP TABLE IF EXISTS folio_reporting.locations_libraries;

CREATE TABLE folio_reporting.locations_libraries AS
SELECT
    inventory_campuses.id AS campus_id,
    inventory_campuses.name AS campus_name,
    inventory_locations.id AS location_id,
    inventory_locations.name AS location_name,
    inventory_locations.discovery_display_name AS discovery_display_name,
    inventory_libraries.id AS library_id,
    inventory_libraries.name AS library_name,
    inventory_institutions.id AS institution_id,
    inventory_institutions.name AS institution_name
FROM
    inventory_campuses
    JOIN inventory_locations ON inventory_campuses.id = inventory_locations.campus_id
    JOIN inventory_institutions ON inventory_locations.institution_id = inventory_institutions.id
    JOIN inventory_libraries ON inventory_locations.library_id = inventory_libraries.id;

CREATE INDEX ON folio_reporting.locations_libraries (campus_id);

CREATE INDEX ON folio_reporting.locations_libraries (campus_name);

CREATE INDEX ON folio_reporting.locations_libraries (location_id);

CREATE INDEX ON folio_reporting.locations_libraries (location_name);

CREATE INDEX ON folio_reporting.locations_libraries (discovery_display_name);

CREATE INDEX ON folio_reporting.locations_libraries (library_id);

CREATE INDEX ON folio_reporting.locations_libraries (library_name);

CREATE INDEX ON folio_reporting.locations_libraries (institution_id);

CREATE INDEX ON folio_reporting.locations_libraries (institution_name);

