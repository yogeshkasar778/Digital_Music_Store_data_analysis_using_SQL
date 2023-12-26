                        
						--Digital music store Data Analyis using SQL--

--Objective:
/*In this project, we shall analyze and answer a few business questions or tasks regarding an online music 
store. With the help of SQL, the analysis will be conducted on the dataset and help the store 
understand the business questions they had put forward in order to meet their requirements.*/

--Questions:

--1. Which countries have the most invoices?

--2. What are the top 3 values of total invoices?

--3. Which city has the best customers? (The company would like to organize a promotional Music Festival in the city where they made the most money)

--4. Who is the best customer? (The customer who has spent the most money will be declared the best customer)

--5. What’s the name and mail ID of the listeners who enjoy Rock Music?

--6. Let's invite the artists who have wriƩen the most rock music in our dataset. Who is it?

--7. Which tracks in the dataset have a song length more than the average song length, and what’s their duration?

--8. Which tracks in the dataset have a song length more than the average song length, and what’s their duration?

--9. Which is the most popular music genre for each country? (Write a query that returns each country along with the top genre. For countries where the maximum number of purchases is shared, return all genres)

--10. Determine the customer who has spent the most on music for each country. (Write a query that returns the country name, the top customer’s name, and how much they spent. For countries where the top amount spent is shared, provide all the customers’ names who spent this amount.)


						                        --Analyis--

/*Question 1. Which countries have the most invoices?*/

select * from invoice;

--Solution:

select top (10) billing_country, count(*) as tol_invoices 
from invoice
group by billing_country
order by tol_invoices desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*2. What are the top 3 values of total invoices?*/

select * from invoice;

--Solution:

select distinct top(3) total
from invoice
order by total desc;

-------------------------------------------------------------------------------------------------------------------------------------------------

/*3. Which city has the best customers? (The company would like to organize a promotional Music Festival in the city where they made the most money)*/

select * from invoice;

--Solution:

select top(10) billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*4. Who is the best customer? (The customer who has spent the most money will be declared the best customer)*/

select * from customer;
select * from invoice;

--Solution:

select top(3) c.customer_id, c.first_name, c.last_name, sum(i.total) as total_invoice
from customer as c
join invoice as i on c.customer_id=i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_invoice desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*5. What’s the name and mail ID of the listeners who enjoy Rock Music?*/

select * from customer;
select * from invoice;
select * from invoice_line;
select * from track;

--Solution 1:

select distinct c.first_name, c.last_name, c.email 
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as i_line on i_line.invoice_id=i.invoice_id
where track_id  in (select track_id from genre as g
                    join track as t on g.genre_id=t.genre_id
				    where g.name like 'Rock')
order by email;

-- Solution 2:

select distinct c.first_name, c.last_name, c.email 
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as i_line on i_line.invoice_id=i.invoice_id
join track as t on t.track_id=i_line.track_id
join genre as g on g.genre_id=t.genre_id
where g.name = 'Rock'
order by email;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*6. Let's invite the artists who have written the most rock music in our dataset. Who is it?*/

select * from track;
select * from album;
select * from artist;
select * from genre;

--Solution:

select top(10) ar.artist_id, ar.name, count(ar.artist_id) as number_of_artiest
from track as t
join album as a on t.album_id=a.album_id
join artist as ar on ar.artist_id=a.artist_id
join genre as g on g.genre_id=t.genre_id
where g.name='Rock'
group by ar.artist_id,ar.name
order by number_of_artiest desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*7. Which tracks in the dataset have a song length more than the average song length, and what’s their duration?*/

select * from track;

--Solution:

select name, milliseconds 
from track
where milliseconds > (select avg(milliseconds)
                      from track)
order by milliseconds desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*8. How much amount was spent by each customer on artists? (Write a query to return the customer’s name, artist name, and total spent.)*/
select * from invoice_line;
select * from track;
select * from album;
select * from artist;

--Solution 1:
select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name, bs.name as artist_name,
       sum(in_l.unit_price*in_l.quantity) as total_amount_spent
from invoice as i
join customer as c on c.customer_id=i.customer_id
join invoice_line as in_l on in_l.invoice_id=i.invoice_id
join track as tr on tr.track_id=in_l.track_id
join album as albm on albm.album_id=tr.album_id
join (
      select top (1) ar.artist_id, ar.name, 
             sum(il.unit_price*il.quantity) as total_spent 
      from invoice_line as il
      join track as t on il.track_id=t.track_id
      join album as a on a.album_id=t.album_id
      join artist as ar on ar.artist_id=a.artist_id
      group by ar.artist_id, ar.name
      order by total_spent desc
	  ) as bs on bs.artist_id=albm.artist_id
group by c.customer_id, concat(c.first_name,' ',c.last_name),bs.name
order by total_amount_spent desc;

--Solution 2:
with best_sell as (select top (1) ar.artist_id, ar.name, 
                          sum(il.unit_price*il.quantity) as total
                   from invoice_line as il
                   join track as t on il.track_id=t.track_id
                   join album as a on a.album_id=t.album_id
                   join artist as ar on ar.artist_id=a.artist_id
                   group by ar.artist_id,ar.name
                   order by total desc
				   )
select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name, bs.name as artist_name, 
       sum(in_l.unit_price*in_l.quantity) as total_amount_spent
from invoice as  i
join customer as c on c.customer_id=i.customer_id
join invoice_line as in_l on in_l.invoice_id=i.invoice_id
join track as tr on tr.track_id=in_l.track_id
join album as alb on alb.album_id=tr.album_id
join best_sell as bs on bs.artist_id=alb.artist_id
group by c.customer_id,concat(c.first_name,' ',c.last_name), bs.name
order by total_amount_spent desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*9. Which is the most popular music genre for each country? (Write a query that returns each country along with the top genre. For countries where the maximum number of purchases is shared, return all genres).*/

select * from invoice_line;
select * from invoice;
select * from customer;
select * from track;
select * from genre;

--Solution 1:

with sales_country as 
(select  g.genre_id,c.country, g.name, count(*) as purchuse_per_customer
from invoice_line as il
join invoice as i on i.invoice_id=il.invoice_id
join customer as c on c.customer_id=i.customer_id
join track as t on t.track_id=il.track_id
join genre as g on g.genre_id=t.genre_id
group by c.country, g.name, g.genre_id),
max_gen_country as (select max(purchuse_per_customer) as max_gen_number, country 
                    from sales_country
					group by country
					)
select sales_country.*
from sales_country
join max_gen_country on sales_country.country=max_gen_country.country
where sales_country.purchuse_per_customer=max_gen_country.max_gen_number;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*10. Determine the customer who has spent the most on music for each country. (Write a query that returns the country name, the top customer’s name, and how much they spent. For countries where the top amount spent is shared, provide all the customers’ names who spent this amount.)*/

select * from invoice;
select * from customer;

--Solution:

with customer_country as
       (select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as total_spend
       from invoice as i
       join customer as c on c.customer_id=i.customer_id
       group by c.customer_id, c.first_name, c.last_name, i.billing_country),
	   
	   max_spend_country as 
	   (select billing_country, max(total_spend) as max_spending 
	   from customer_country
	   group by billing_country)

select cc.customer_id,concat(cc.first_name,' ',cc.last_name) as customer_name,cc.billing_country,cc.total_spend
from customer_country as cc
join max_spend_country as mc on cc.billing_country=mc.billing_country
where cc.total_spend=mc.max_spending
order by cc.billing_country asc;

-----------------------------------------------------------------------------------------------------------------------------------------------
                                                 --Thank You!