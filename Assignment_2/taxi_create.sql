DROP DATABASE IF EXISTS taxi;
CREATE DATABASE taxi;
USE taxi;

CREATE TABLE drivers (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE customers (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE rides (
    id CHAR(36) PRIMARY KEY,
    driver_id CHAR(36),
    customer_id CHAR(36),
    distance_km DECIMAL(5,2),
    price DECIMAL(7,2),
    ride_date DATE
);

select count(*) from drivers;
select count(*) from customers;
select count(*) from rides;


-- -------------------------------------------------------------
explain analyze
SELECT c.city, AVG(r.price) AS avg_price
FROM rides r
JOIN customers c ON r.customer_id = c.id
JOIN drivers d ON r.driver_id = d.id
WHERE r.price between 20 and 70
  AND YEAR(r.ride_date) = 2024 -- using a non-sargable expression (YEAR on ride_date) 
  AND d.region IN (  -- correlated subquery-like structure
	SELECT region 
	FROM drivers 
	WHERE region = 'North' OR region = 'South'
  )  -- useless subquery
GROUP BY c.city
HAVING AVG(r.price) > (
	SELECT AVG(price) 
	FROM rides 
	WHERE price > 10
  )  -- extra full-scan subquery
ORDER BY avg_price DESC
LIMIT 10;


-- --------------------------------------
show indexes from rides;

drop index idx_rides_date_price_driver_customer on rides;
CREATE INDEX idx_rides_date_price_driver_customer
ON rides (driver_id, customer_id, price, ride_date);

show indexes from drivers;

explain analyze
WITH  -- prefilter rides to the year 2024 and price > 20 (sargable)
  filtered_rides AS (
    SELECT    
		id, driver_id, customer_id, price, ride_date
    FROM rides USE INDEX (idx_rides_date_price_driver_customer) 
    WHERE ride_date >= '2024-01-01' AND ride_date < '2025-01-01'  -- sargable range
      AND price between 20 and 70
  ),
  north_south_drivers AS (
    SELECT 
		id
    FROM drivers
    WHERE region IN ('North', 'South')
  )
SELECT /*+ JOIN_ORDER(filtered_rides, north_south_drivers, customers) */
	c.city, AVG(fr.price) AS avg_price
FROM filtered_rides fr
JOIN north_south_drivers nd ON fr.driver_id = nd.id  
JOIN customers c ON fr.customer_id = c.id
GROUP BY c.city
ORDER BY avg_price DESC
LIMIT 10;



