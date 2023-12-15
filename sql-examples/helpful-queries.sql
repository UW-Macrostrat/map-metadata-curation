SELECT * FROM information_schema.tables WHERE table_schema = 'sources' AND table_name LIKE '%_polygons';

SELECT
	source_id
FROM maps.sources;