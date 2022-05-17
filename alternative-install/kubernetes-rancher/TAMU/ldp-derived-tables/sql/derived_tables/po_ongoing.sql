DROP TABLE IF EXISTS folio_reporting.po_ongoing;

-- Create a local table for ongoing details in purchase orders.
CREATE TABLE folio_reporting.po_ongoing AS
SELECT
    po.id AS po_id,
    json_extract_path_text(data, 'ongoing', 'interval')::INT AS po_ongoing_interval,
    json_extract_path_text(data, 'ongoing', 'isSubscription')::BOOLEAN AS po_ongoing_is_subscription,
    json_extract_path_text(data, 'ongoing', 'manualRenewal')::BOOLEAN AS po_ongoing_manual_renewal,
    json_extract_path_text(data, 'ongoing', 'renewalDate')::TIMESTAMP WITH TIME ZONE AS po_ongoing_renewal_date,
    json_extract_path_text(data, 'ongoing', 'reviewPeriod')::INT AS po_ongoing_review_period
FROM
    po_purchase_orders AS po;

CREATE INDEX ON folio_reporting.po_ongoing (po_id);

CREATE INDEX ON folio_reporting.po_ongoing (po_ongoing_interval);

CREATE INDEX ON folio_reporting.po_ongoing (po_ongoing_is_subscription);

CREATE INDEX ON folio_reporting.po_ongoing (po_ongoing_manual_renewal);

CREATE INDEX ON folio_reporting.po_ongoing (po_ongoing_renewal_date);

CREATE INDEX ON folio_reporting.po_ongoing (po_ongoing_review_period);

