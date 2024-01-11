1. Which countries have the most invoices.?
   
Solution:
```SQL
SELECT TOP (10) billing_country, COUNT(*) AS tol_invoices 
FROM invoice
GROUP BY billing_country
ORDER BY tol_invoices desc;
```
2. What are the top 3 values of total invoices?

Solution:
```SQL
SELECT DISTINCT TOP(3) total
FROM invoice
ORDER BY total desc;
```
3. Which city has the best customers? (The company would like to organize a promotional Music Festival in the city where they made the most money)
   
Solution:
```SQL
SELECT TOP(10) billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice desc;
```     
4. Who is the best customer? (The customer who has spent the most money will be declared the best customer)

Solution:
```SQL
SELECT TOP(3) c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_invoice
FROM customer AS c
JOIN invoice AS i ON c.customer_id=i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_invoice desc;
```  
5. What’s the name and mail ID of the listeners who enjoy Rock Music?

Solution 1:
```SQL
SELECT DISTINCT c.first_name, c.last_name, c.email 
FROM customer AS c
JOIN invoice AS i ON c.customer_id=i.customer_id
JOIN invoice_line AS i_line ON i_line.invoice_id=i.invoice_id
WHERE track_id  IN (SELECT track_id FROM genre AS g
                    JOIN track AS t ON g.genre_id=t.genre_id
				            WHERE g.name LIKE 'Rock')
ORDER BY email;
```
Solution 2:

```SQL
SELECT DISTINCT c.first_name, c.last_name, c.email 
FROM customer AS c
JOIN invoice AS i ON c.customer_id=i.customer_id
JOIN invoice_line AS i_line ON i_line.invoice_id=i.invoice_id
JOIN track AS t ON t.track_id=i_line.track_id
JOIN genre AS g ON g.genre_id=t.genre_id
WHERE g.name = 'Rock'
ORDER BY email;
```
6. Let's invite the artists who have written the most rock music in our dataset. Who is it?
   
Solution 2:
```SQL
SELECT TOP(10) ar.artist_id, ar.name, COUNT(ar.artist_id) AS number_of_artiest
FROM track AS t
JOIN album AS a ON t.album_id=a.album_id
JOIN artist AS ar ON ar.artist_id=a.artist_id
JOIN genre AS g ON g.genre_id=t.genre_id
WHERE g.name='Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY number_of_artiest DESC;
```
7. Which tracks in the dataset have a song length more than the average song length, and what’s their duration?

Solution:
```SQL
SELECT name, milliseconds 
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds)
                      FROM track)
ORDER BY milliseconds DESC;
```
8. How much amount was spent by each customer on artists? (Write a query to return the customer’s name, artist name, and total spent.)

Solution 1:
```SQL
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name, bs.name AS artist_name,
       SUM(in_l.unit_price*in_l.quantity) AS total_amount_spent
FROM invoice AS i
JOIN customer AS c ON c.customer_id=i.customer_id
JOIN invoice_line AS in_l ON in_l.invoice_id=i.invoice_id
JOIN track AS tr ON tr.track_id=in_l.track_id
JOIN album AS albm ON albm.album_id=tr.album_id
JOIN (
      SELECT TOP (1) ar.artist_id, ar.name, 
             SUM(il.unit_price*il.quantity) AS total_spent 
      FROM invoice_line AS il
      JOIN track AS t ON il.track_id=t.track_id
      JOIN album AS a ON a.album_id=t.album_id
      JOIN artist AS ar ON ar.artist_id=a.artist_id
      GROUP BY ar.artist_id, ar.name
      ORDER BY total_spent desc
	   ) AS bs ON bs.artist_id=albm.artist_id
GROUP BY c.customer_id, CONCAT(c.first_name,' ',c.last_name), bs.name
ORDER BY total_amount_spent DESC;
```
Solution 2:
```SQL
WITH best_sell AS (SELECT TOP (1) ar.artist_id, ar.name, 
                          SUM(il.unit_price*il.quantity) AS total
                   FROM invoice_line AS il
                   JOIN track AS t ON il.track_id=t.track_id
                   JOIN album AS a ON a.album_id=t.album_id
                   JOIN artist AS ar ON ar.artist_id=a.artist_id
                   GROUP BY ar.artist_id, ar.name
                   ORDER BY total desc
				           )
SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) AS customer_name, bs.name AS artist_name, 
       SUM(in_l.unit_price*in_l.quantity) AS total_amount_spent
FROM invoice AS i
JOIN customer AS c ON c.customer_id=i.customer_id
JOIN invoice_line AS in_l ON in_l.invoice_id=i.invoice_id
JOIN track AS tr ON tr.track_id=in_l.track_id
JOIN album AS alb ON alb.album_id=tr.album_id
JOIN best_sell AS bs ON bs.artist_id=alb.artist_id
GROUP BY c.customer_id, CONCAT(c.first_name,' ',c.last_name), bs.name
ORDER BY total_amount_spent DESC;
```
9. Which is the most popular music genre for each country? (Write a query that returns each country along with the top genre. For countries where the maximum number of purchases is shared, return all genres).

Solution:
```SQL
WITH sales_country AS
(SELECT  g.genre_id,c.country, g.name, COUNT(*) AS purchuse_per_customer
FROM invoice_line AS il
JOIN invoice AS i ON i.invoice_id=il.invoice_id
JOIN  customer AS c ON c.customer_id=i.customer_id
JOIN track AS t ON t.track_id=il.track_id
JOIN genre AS g ON g.genre_id=t.genre_id
GROUP BY c.country, g.name, g.genre_id),
max_gen_country AS (SELECT MAX(purchuse_per_customer) AS max_gen_number, country 
                    FROM sales_country
					          GROUP BY country
                   )
SELECT sales_country.*
FROM sales_country
JOIN max_gen_country ON sales_country.country=max_gen_country.country
WHERE sales_country.purchuse_per_customer=max_gen_country.max_gen_number;
```
10. Determine the customer who has spent the most on music for each country. (Write a query that returns the country name, the top customer’s name, and how much they spent. For countries where the top amount spent is shared, provide all the customers’ names who spent this amount.)

Solution:
```SQL
WITH customer_country AS
       (SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS total_spend
       FROM invoice AS i
       JOIN customer AS c ON c.customer_id=i.customer_id
       GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country),
	   
	   max_spend_country AS 
	    (SELECT billing_country, MAX(total_spend) AS max_spending 
	    FROM customer_country
	    GROUP BY billing_country)

SELECT cc.customer_id, CONCAT(cc.first_name,' ',cc.last_name) AS customer_name, cc.billing_country, cc.total_spend
FROM customer_country AS cc
JOIN max_spend_country AS mc ON cc.billing_country=mc.billing_country
WHERE cc.total_spend=mc.max_spending
ORDER BY cc.billing_country ASC;
```
---------------------------------------------------------------------- Thank You!----------------------------------------------------------------
