1. Which countries have the most invoices.?
```SQL
SELECT top (10) billing_country, count(*) as tol_invoices 
from invoice
group by billing_country
order by tol_invoices desc;
```
2.   

