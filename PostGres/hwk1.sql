-- Qn1
SELECT relname FROM pg_class
WHERE relkind='r' AND relname NOT LIKE '%pg_%' AND relname NOT LIKE '%sql_%';

--Qn2
SELECT c.countries FROM events e 
JOIN venues v ON e.venue_id=v.venue_id
JOIN countries c ON v.country_code=c.country_code
WHERE e.title='LARP Club';

--Qn3
ALTER TABLE venues
ADD active boolean DEFAULT true;



