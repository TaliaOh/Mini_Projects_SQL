------------------------Mini project 1----------------------

-------1--------

-- SELECT first_name , last_name, SUM(amount)
-- FROM 
-- 	customer JOIN rental  
-- 	   ON customer.customer_id = rental.customer_id 
-- 	 JOIN payment
-- 	   ON rental.rental_id = payment.rental_id
-- GROUP BY first_name , last_name
-- ORDER BY SUM(amount)

------2-------

-- SELECT EXTRACT(HOUR FROM rental_date), COUNT(rental_id)
-- FROM rental
-- GROUP BY EXTRACT(HOUR FROM rental_date)
-- ORDER BY COUNT(rental_id) 

------3--------

-- SELECT film.title, COUNT(film.title)
-- 	FROM inventory JOIN film
-- 		ON inventory.film_id = film.film_id
-- GROUP BY film.title
-- HAVING film.title = 'Mine Titans'

------4---------

-- SELECT film.title,inventory.store_id , COUNT(film.title) 
-- FROM inventory JOIN film
-- ON inventory.film_id = film.film_id
-- GROUP BY film.title , inventory.store_id
-- HAVING film.title = 'Mine Titans'

---------------------------Mini Project 2-------------------------
--TRIGGER

-- 1.create a new table
CREATE TABLE IF NOT EXISTS audit(
	id SERIAL PRIMARY KEY ,
	user_name TEXT , 
	event_time TIMESTAMPTZ,
	table_name TEXT,
	operation TEXT,
	old_value JSON,
	new_value JSON
)

--2.create the func
CREATE OR REPLACE FUNCTION audit_func() RETURNS TRIGGER AS 
$$
DECLARE 
	old_row JSON := NULL;
	new_row JSON := NULL;

BEGIN
	IF TG_OP in( 'UPDATE' , 'INSERT') THEN 
		new_row=row_to_json(NEW);
	END IF;
	--insert all the data into a row
	INSERT INTO audit(
		user_name,
		event_time,
		table_name,
		operation,
		old_value,
		new_value
	)
	VALUES
	(
		session_user,
		current_timestamp AT TIME ZONE 'UTC',
		CONCAT(TG_TABLE_SCHEMA , '.' , TG_TABLE_NAME),
		TG_OP,
		old_row,
		new_row
	);
	RETURN NEW;
END;
$$ language 'plpgsql'

--3.create trigger
CREATE TRIGGER audit_trigger
AFTER INSERT OR UPDATE OR DELETE
ON people
FOR EACH ROW 
EXECUTE PROCEDURE audit_func()

--4.change the people table
 INSERT INTO people (name, gender, age)
 VALUES
    ('Hans', 'M', 45),
    ('Ragnar', 'M', 37);

UPDATE people SET name = 'Billy Bob' WHERE name = 'Hans';

DELETE FROM people WHERE name = 'Billy Bob' ;

UPDATE people SET age = 15 WHERE name = 'Joe';

SELECT * FROM audit;
