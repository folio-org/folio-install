DROP TABLE IF EXISTS folio_reporting.item_notes;

-- Create a local table for notes in item records. Here note is a public note.
CREATE TABLE folio_reporting.item_notes AS
SELECT
    items.id AS item_id,
    items.hrid AS item_hrid,
    holdings_record_id AS holdings_record_id,
    json_extract_path_text(notes.data, 'itemNoteTypeId') AS note_type_id,
    item_note_types.name AS note_type_name,
    json_extract_path_text(notes.data, 'note') AS note,
    json_extract_path_text(notes.data, 'staffOnly')::boolean AS staff_only,
    notes.ordinality AS note_ordinality
FROM
    inventory_items AS items
    CROSS JOIN LATERAL json_array_elements(json_extract_path(data, 'notes')) WITH ORDINALITY AS notes (data)
    LEFT JOIN inventory_item_note_types AS item_note_types ON json_extract_path_text(notes.data, 'itemNoteTypeId') = item_note_types.id;

CREATE INDEX ON folio_reporting.item_notes (item_id);

CREATE INDEX ON folio_reporting.item_notes (item_hrid);

CREATE INDEX ON folio_reporting.item_notes (holdings_record_id);

CREATE INDEX ON folio_reporting.item_notes (note_type_id);

CREATE INDEX ON folio_reporting.item_notes (note_type_name);

CREATE INDEX ON folio_reporting.item_notes (note);

CREATE INDEX ON folio_reporting.item_notes (staff_only);

CREATE INDEX ON folio_reporting.item_notes (note_ordinality);

