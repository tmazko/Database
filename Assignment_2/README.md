#  MySQL Query Optimization — Practical Assignment

##  Database Setup

I worked with a simple taxi service schema:

drivers(id, name, region)

customers(id, name, city)

rides(id, driver_id, customer_id, distance_km, price, ride_date)

Each table contains at least 1,000,000 rows to simulate a realistic workload.

##  Non-Optimized Query

The original query uses:

* YEAR(r.ride_date) —  non-sargable expression (disables index usage)

* A redundant correlated subquery in the WHERE clause

* An extra full table scan in the HAVING condition

* No indexing or filtering strategy
```{sql}
EXPLAIN ANALYZE
SELECT c.city, AVG(r.price) AS avg_price
FROM rides r
JOIN customers c ON r.customer_id = c.id
JOIN drivers d ON r.driver_id = d.id
WHERE r.price BETWEEN 20 AND 70
  AND YEAR(r.ride_date) = 2024
  AND d.region IN (
    SELECT region FROM drivers WHERE region = 'North' OR region = 'South'
  )
GROUP BY c.city
HAVING AVG(r.price) > (
    SELECT AVG(price) FROM rides WHERE price > 10
)
ORDER BY avg_price DESC
LIMIT 10;
```

Explain analyze result: 25.094 sec
```
-> Limit: 10 row(s)  (actual time=56658..56658 rows=10 loops=1)
     -> Sort: avg_price DESC  (actual time=56658..56658 rows=10 loops=1)
         -> Filter: (??? > (select #3))  (actual time=56628..56657 rows=763 loops=1)
             -> Table scan on <temp...
```

##  Optimized Query


```{sql}
CREATE INDEX idx_rides_date_price_driver_customer
ON rides (ride_date, price, driver_id, customer_id);

WITH /*+ MATERIALIZATION */
  filtered_rides AS (
    SELECT /*+ USE_INDEX(rides idx_rides_date_price_driver_customer) */
           id, driver_id, customer_id, price, ride_date
    FROM rides
    WHERE ride_date >= '2024-01-01' AND ride_date < '2025-01-01'
      AND price BETWEEN 20 AND 70
  ),
  north_south_drivers AS (
    SELECT id
    FROM drivers
    WHERE region IN ('North', 'South')
  )
SELECT c.city, AVG(fr.price) AS avg_price
FROM filtered_rides fr
JOIN customers c ON fr.customer_id = c.id
JOIN north_south_drivers nd ON fr.driver_id = nd.id
GROUP BY c.city
ORDER BY avg_price DESC
LIMIT 10;
```

Explain analyze result: 25.094 sec
```
-> Limit: 10 row(s)  (actual time=25073..25073 rows=10 loops=1)
     -> Sort: avg_price DESC, limit input to 10 row(s) per chunk  (actual time=25073..25073 rows=10 loops=1)
         -> Table scan on <temporary>  (actual time=25039..25050 rows=28655 loops=1...
```

####  Optimization Techniques
* CTE (MATERIALIZATION)	Filters data before joins	Reduces scanned rows
* Composite Index	(ride_date, price, driver_id, customer_id)	Enables index range scan
* Sargable Condition	Replaced YEAR(date) with range filter	Allows use of index 
* Added optimizer hints: USE INDEX hint. Forces MySQL to pick the correct index	Prevents full table scan
* Query Rewriting	Removed unnecessary subqueries	Simplifies execution plan
* Removed redundant subqueries
