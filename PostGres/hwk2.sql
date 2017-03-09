--Qn1
DROP RULE IF EXISTS delete_venue ON venues;

CREATE RULE delete_venue AS ON DELETE TO venues DO INSTEAD
UPDATE venues
SET active = false
WHERE name = OLD.name;

SELECT * FROM venues;
DELETE FROM venues WHERE name = 'Voodoo Donuts';
SELECT * FROM venues;

--Qn2
SELECT * FROM crosstab (
  'SELECT extract(year from start) as year, 
  extract(month from start) as month, count(*)
  FROM events GROUP BY year, month',
  'SELECT generate_series(1,12)'
) AS (
  year int,
  jan int, feb int, mar int, apr int, may int, jun int, jul int, aug int, sep int, oct int, nov int, dec int  
) ORDER BY YEAR;

--Qn3
-- SELECT * FROM events;

CREATE OR REPLACE FUNCTION events_of_month(year int, month int)
RETURNS TABLE(week double precision, day double precision, count bigint) AS $$
DECLARE
num_weeks integer;
first_day timestamp;
last_day timestamp;
month_str text;
year_str text;
BEGIN
CREATE TEMP TABLE temp_table AS
SELECT extract(week from start)-extract(week from date_trunc('month', start)) + 1 as week,
extract(dow from start) as day,
count(*) FROM events WHERE extract(year from start)=year AND extract(month from start)=month
GROUP BY week, day
ORDER BY week;

first_day := to_date(month::text || '-' || year::text, 'YYYY-MM');
last_day := first_day + INTERVAL '1' MONTH - INTERVAL '1' DAY;
num_weeks := extract(week from last_day) - extract(week from first_day) + 1;

WHILE num_weeks > 0 LOOP
  PERFORM * FROM temp_table WHERE temp_table.week=num_weeks;
  IF NOT FOUND THEN
    INSERT INTO temp_table (week, day, count) VALUES(num_weeks,null,null);
  END IF;  
  num_weeks := num_weeks - 1;
END LOOP;

RETURN QUERY SELECT * FROM temp_table;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM crosstab(
  'SELECT * FROM events_of_month(2012,2)',
  'SELECT generate_series(0,6)'
) AS (
  week int,
  Sun int, Mon int, Tue int, Wed int, Thu int, Fri int, Sat int
) ORDER BY week;