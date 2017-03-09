--Qn2
-- CREATE TABLE users(
--   user_id SERIAL PRIMARY KEY,
--   name varchar(55)
-- );

-- CREATE TABLE comments(
--   comment_id SERIAL PRIMARY KEY,
--   user_id integer REFERENCES users NOT NULL,
--   comment text
-- );

-- INSERT INTO users (name) VALUES('John');
-- INSERT INTO users (name) VALUES('Sandy');
-- INSERT INTO users (name) VALUES('Omega');

-- INSERT INTO comments (user_id, comment) VALUES(1, 'I like johnny depp');
-- INSERT INTO comments (user_id, comment) VALUES(2, 'I prefer Sandra Bullock.');
-- INSERT INTO comments (user_id, comment) VALUES(3, 'maybe willis is better');
-- INSERT INTO comments (user_id, comment) VALUES(1, 'bruce willis sucks');
-- INSERT INTO comments (user_id, comment) VALUES(2, 'yes bruce willis sucks');
-- INSERT INTO comments (user_id, comment) VALUES(3, 'okok johnny depp is better');

DROP FUNCTION most_talked_about_actors();

CREATE OR REPLACE FUNCTION most_talked_about_actors()
RETURNS TABLE(name text, count bigint) AS $$
DECLARE
BEGIN

RETURN QUERY SELECT a.name, count(*) count
FROM actors a, comments c
WHERE to_tsvector(c.comment) @@ to_tsquery('simple', regexp_replace(lower(regexp_replace(a.name, '^.* ', '')), '\W+', '', 'g'))
GROUP BY a.name
ORDER BY count;

END;
$$ LANGUAGE plpgsql;

SELECT most_talked_about_actors();