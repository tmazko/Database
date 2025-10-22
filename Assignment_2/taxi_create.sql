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
