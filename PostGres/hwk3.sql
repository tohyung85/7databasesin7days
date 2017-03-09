DROP FUNCTION get_top_5(text);
--Qn1
CREATE OR REPLACE FUNCTION get_top_5(input_text text)
RETURNS TABLE(result text) AS $$
DECLARE
best_actor_match text;
best_movie_match text;
actor_lev int;
movie_lev int;
BEGIN
CREATE TEMP TABLE temp_table (
  title text
);

SELECT name into best_actor_match
FROM actors 
WHERE metaphone(name, 6) % metaphone(input_text, 6)
ORDER BY levenshtein(lower(name), lower(input_text))
LIMIT 1;

SELECT movies.title into best_movie_match
FROM movies 
WHERE to_tsvector('simple', movies.title) @@ to_tsquery(replace(input_text, ' ', '&'))
LIMIT 1;

actor_lev := levenshtein(input_text, best_actor_match);
movie_lev := levenshtein(input_text, best_movie_match);

IF actor_lev IS NULL OR movie_lev > actor_lev THEN
  RETURN QUERY SELECT m.title
  FROM movies m, (SELECT genre, title FROM movies WHERE title = best_movie_match) s
  WHERE cube_enlarge(s.genre, 5, 18) @> m.genre AND s.title <> m.title
  ORDER BY cube_distance(m.genre, s.genre)
  LIMIT 5;
ELSIF movie_lev IS NULL OR actor_lev > movie_lev THEN
  RETURN QUERY SELECT m.title
  FROM movies m NATURAL JOIN movies_actors NATURAL JOIN actors a
  WHERE a.name = best_actor_match
  LIMIT 5;
ELSE
  RETURN QUERY SELECT * FROM temp_table;
END IF;

END;

$$ LANGUAGE plpgsql;

SELECT get_top_5('Johnny Depp');