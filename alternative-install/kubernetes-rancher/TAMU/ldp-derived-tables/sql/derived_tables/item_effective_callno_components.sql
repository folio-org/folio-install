DROP TABLE IF EXISTS folio_reporting.item_effective_callno_components;

--Create table for item effective call number components
CREATE TABLE folio_reporting.item_effective_callno_components AS

WITH items AS (
	SELECT
		item.id AS item_id,
		item.hrid AS item_hrid,
		json_extract_path_text(data, 'effectiveCallNumberComponents', 'prefix') AS effective_call_number_prefix,
		json_extract_path_text(data, 'effectiveCallNumberComponents','callNumber') AS effective_call_number,
		json_extract_path_text(data, 'effectiveCallNumberComponents', 'suffix') AS effective_call_number_suffix,
		json_extract_path_text(data, 'effectiveCallNumberComponents', 'typeID') AS effective_call_number_type_id
	FROM
		inventory_items AS item
)
SELECT
	items.item_id,
	items.item_hrid,
	items.effective_call_number_prefix,
	items.effective_call_number,
	items.effective_call_number_suffix,
	items.effective_call_number_type_id,
	inventory_call_number_types.name AS effective_call_number_type_name
FROM
       items
       LEFT JOIN inventory_call_number_types ON items.effective_call_number_type_id = inventory_call_number_types.id;
      
CREATE INDEX ON folio_reporting.item_effective_callno_components (item_id);

CREATE INDEX ON folio_reporting.item_effective_callno_components (item_hrid);

CREATE INDEX ON folio_reporting.item_effective_callno_components (effective_call_number_prefix);

CREATE INDEX ON folio_reporting.item_effective_callno_components (effective_call_number);

CREATE INDEX ON folio_reporting.item_effective_callno_components (effective_call_number_suffix);

CREATE INDEX ON folio_reporting.item_effective_callno_components (effective_call_number_type_id);

CREATE INDEX ON folio_reporting.item_effective_callno_components (effective_call_number_type_name);
