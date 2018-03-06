-- 1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name," ",last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id,first_name,last_name from actor where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
select actor_id,first_name,last_name from actor where last_name like "%LI%"
order by last_name desc, first_name desc;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select country_id,country from country where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
alter table actor
ADD column middle_name varchar(45)
AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.

alter table actor
modify column middle_name blob
AFTER first_name;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select count(actor_id),last_name from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select count(actor_id),last_name from actor 
group by last_name having count(actor_id) > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
-- Confirm the number of records
-- select * from actor WHERE first_name= 'GROUCHO' and last_name = 'WILLIAMS';
UPDATE actor SET first_name='HARPO' WHERE first_name='GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.
-- Check if there is an actor with first name HARPO and get the unique identifier
-- select * from actor where first_name= 'HARPO';
UPDATE actor 
SET first_name= IF(first_name= 'GROUCHO','HARPO','MUCHO GROUCHO') where actor_id = 172;
-- select * from actor where first_name = 'MUCHO GROUCHO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE address (
  address_id INTEGER(5) NOT NULL PRIMARY KEY,
  address VARCHAR(50),
  address2 VARCHAR(50),
  district VARCHAR(20),
  city_id INTEGER(5),
  postal_code VARCHAR(10),
  phone VARCHAR(20),
  location geometry,
  last_update timestamp
);

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name,a.address,a.address2, a.address,a.city_id,a.postal_code  from
staff as s
left join address as a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name,sum(p.amount) as 'Total Amount',p.payment_date from
staff as s
left join payment as p
on s.staff_id = p.staff_id
where month(p.payment_date) = '08' && year(p.payment_date) = '2005'
group by first_name,last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title,count(fa.actor_id) as 'Total Actors'
from film as f
join film_actor as fa
on f.film_id = fa.film_id
group by fa.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(i.inventory_id) as 'No. of copies' from inventory as i
join film as f
on i.film_id = f.film_id
where f.title = 'Hunchback Impossible'
group by i.film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name.
select c.first_name,c.last_name,sum(p.amount) as 'Total Amount paid' from 
customer as c
join payment as p
where c.customer_id = p.customer_id
group by p.customer_id
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select f.title
from film as f
where (f.title like 'K%' or f.title like 'Q%') and language_id = (select language_id from language where name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select a.first_name,a.last_name from actor as a where actor_id in 
(select actor_id from film_actor where film_id = 
(select film_id from film where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select c.first_name, c.last_name,c.email
from customer as c
join address as a
on c.address_id = a.address_id
join city as ci
on a.city_id = ci.city_id
join country as co
on co.country_id = ci.country_id
where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
select f.title from
film as f
join film_category as fc
on f.film_id=fc.film_id
join category as c
on fc.category_id = c.category_id
where c.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
select title,rental_rate from film
order by rental_rate desc limit 400;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as 'Business bought in by $Amount'
from store as s
join inventory as i
on s.store_id = i.store_id
join rental as r
on i.inventory_id = r.inventory_id
join payment as p
on p.rental_id = r.rental_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id,ci.city,co.country
from store as s
join address as a
on s.address_id = a.address_id
join city as ci
on a.city_id = ci.city_id
join country as co
on ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select c.name as 'Genre', sum(p.amount) as 'Gross Revenue'
from category as c
join
film_category as fc
on c.category_id = fc.category_id
join
inventory as i
on fc.film_id = i.film_id
join
rental as r
on i.inventory_id = r.inventory_id
join payment as p
on p.rental_id = r.rental_id 
group by c.name
order by p.amount desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW sakila.v_topfivegenres as
select c.name as 'Genre', sum(p.amount)
from category as c
join
film_category as fc
on c.category_id = fc.category_id
join
inventory as i
on fc.film_id = i.film_id
join
rental as r
on i.inventory_id = r.inventory_id
join payment as p
on p.rental_id = r.rental_id 
group by c.name
order by p.amount desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from v_topfivegenres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW  IF EXISTS sakila.v_topfivegenres;

