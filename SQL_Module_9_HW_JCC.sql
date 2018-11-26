USE sakila;

# 1a. Display first and last names of all actors from table "actor"
SELECT first_name, last_name FROM actor;

# 1b. Display first and last name of each actor in a column in upper case; 
# name the column `Actor Name`
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS Actor_Name
FROM actor;

# 2a. You need to find ID number, first, and last name of an actor, of whom the first name is "Joe" 
# What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = "Joe";

# 2b. Find all actors whose last name contain the letters `GEN`
SELECT first_name, last_name 
FROM actor
WHERE lower(last_name) LIKE "%gen%";

# 2c. Find all actors whose last names contain the letters `LI`. 
# This time, order the rows by last name and first name, in that order.
SELECT first_name, last_name 
FROM actor
WHERE LOWER(last_name) LIKE "%LI%"
ORDER BY last_name, first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries 
# Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ("afghanistan", "bangladesh", "china"); 

# 3a. You want to keep a description of each actor. You don't think you will be performing 
# queries on a description, so create a column in the table `actor` named `description` and 
# use the data type `BLOB` (Make sure to research the type `BLOB`, 
# as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

# 3b. Very quickly you realize that entering descriptions for each actor 
# is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name) AS CountOf 
FROM actor 
GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name, 
# but only for names that are shared by at least two actors
SELECT DISTINCT last_name, COUNT(last_name) AS CountOf 
FROM actor 
GROUP BY last_name
HAVING CountOf >= '2';

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
# `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
# It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, 
# change it to `GROUCHO`.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

## Test results from previous two questions
SELECT * FROM actor
WHERE last_name = "WILLIAMS";

# 5a. You cannot locate the schema of the `address` table. 
# Which query would you use to re-create it?
SHOW CREATE TABLE address;
## output from this query can be used to recreate the address table

# 6a. Use `JOIN` to display the first and last names, as well as the address, 
# of each staff member. Use the tables `staff` and `address'
SELECT staff.first_name, staff.last_name, address.address
FROM address
INNER JOIN staff ON address.address_id = staff.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
# Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS Total_Amount
FROM payment 
INNER JOIN staff ON payment.staff_id = staff.staff_id
WHERE payment.payment_date >= "2005-08-01" AND payment_date < "2005-09-01"
GROUP BY staff.last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.film_id, title, COUNT(film_actor.actor_id) AS Number_of_Actors
FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id
GROUP BY title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, film.film_id, COUNT(inventory_id)
FROM inventory
INNER JOIN film ON film.film_id = inventory.film_id
WHERE title LIKE 'Hunchback Impossible';

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(amount) AS Total_Paid
FROM payment
INNER JOIN customer ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name; 

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title IN (
	SELECT title
	FROM film
	WHERE language_id = '1' AND title LIKE 'K%' OR title LIKE 'Q%'
	);

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name #AND actor.last_name as Actor_Name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN(
		SELECT film_id
        FROM film
        WHERE title LIKE 'Alone Trip'
		)
	);

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country.country
FROM customer
INNER JOIN address ON address.address_id = customer.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id
WHERE country.country LIKE 'CANADA'
ORDER BY last_name;

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT film.title, category.name
FROM film
INNER JOIN film_category ON film_category.film_id = film.film_id
INNER JOIN category ON category.category_id = film_category.category_id
WHERE category.name LIKE 'family';

# 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental_id) as Total_Rentals
FROM film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY film.title
ORDER BY Total_Rentals DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, sum(amount) as Revenue_Per_Store
FROM payment 
INNER JOIN rental ON rental.rental_id = payment.rental_id
INNER JOIN staff ON staff.staff_id = rental.staff_id
INNER JOIN store ON store.store_id = staff.store_id
GROUP BY store.store_id
ORDER BY Revenue_Per_Store DESC;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address ON address.address_id = store.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id;

# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS Gross_Revenue
FROM category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
create view Top_Five_Genres_Revenue as
SELECT category.name, SUM(payment.amount) AS Gross_Revenue
FROM category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

# 8b. How would you display the view that you created in 8a?
SELECT * from top_five_genres_revenue;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS sakila.top_five_genres_revenue;