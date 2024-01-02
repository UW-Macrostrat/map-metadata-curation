/**
Initial creation
*/
CREATE TABLE IF NOT EXISTS maps_metadata.sources AS
SELECT
	source_id
FROM maps.sources;

/**
  Add columns
*/
ALTER TABLE maps_metadata.sources ADD COLUMN raster_source_url TEXT;
ALTER TABLE maps_metadata.sources ADD COLUMN raster_bucket_url TEXT;
ALTER TABLE maps_metadata.sources ADD COLUMN compiler_name TEXT;
ALTER TABLE maps_metadata.sources ADD COLUMN date_compiled TIMESTAMP;

/**
  Create view that summarizes the information with context
*/
DROP VIEW IF EXISTS maps_metadata.sources_meta;
CREATE VIEW maps_metadata.sources_meta AS
SELECT
	ms.*,
	name,
	url,
	ref_title,
	authors,
	ref_year,
	ref_source,
	isbn_doi,
	scale,
	licence,
	features,
	area,
	priority,
	display_scales,
	status_code,
	slug
FROM maps.sources s
LEFT JOIN maps_metadata.sources ms
  ON ms.source_id = s.source_id;

/* Triggers to update table every time view is update. They have to be recreated every time you update the view. */
CREATE OR REPLACE FUNCTION maps_metadata.maps_metadata_update_trigger()
	RETURNS TRIGGER
	AS $$
BEGIN
	UPDATE
		maps_metadata.sources
	SET
		raster_source_url = NEW.raster_source_url,
		raster_bucket_url = NEW.raster_bucket_url,
		compiler_name = NEW.compiler_name,
		date_compiled = NEW.date_compiled
	WHERE source_id = NEW.source_id;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER maps_metadata_update_trigger
	INSTEAD OF UPDATE ON maps_metadata.sources_meta
	FOR EACH ROW
	EXECUTE PROCEDURE maps_metadata.maps_metadata_update_trigger();


