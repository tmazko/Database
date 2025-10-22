import random
import uuid
import mysql.connector
from faker import Faker
from datetime import datetime, timedelta

def generate_driver_record(fake: Faker) -> tuple:
    """Generate a single driver record."""
    driver_id = str(uuid.uuid4())
    name = fake.name()
    region = random.choice(["North", "South", "East", "West", "Central"])
    return (driver_id, name, region)

def generate_customer_record(fake: Faker) -> tuple:
    """Generate a single customer record."""
    customer_id = str(uuid.uuid4())
    name = fake.name()
    city = fake.city()
    return (customer_id, name, city)

def generate_ride_record(driver_ids, customer_ids, fake: Faker) -> tuple:
    """Generate a single ride record."""
    ride_id = str(uuid.uuid4())
    driver_id = random.choice(driver_ids)
    customer_id = random.choice(customer_ids)
    distance = round(random.uniform(1, 50), 2)
    price = round(distance * random.uniform(1.5, 3.5), 2)
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2025, 10, 1)
    ride_date = fake.date_between(start_date=start_date, end_date=end_date)
    return (ride_id, driver_id, customer_id, distance, price, ride_date)

def insert_taxi_data(
    host: str,
    user: str,
    password: str,
    database: str,
    num_drivers: int = 100_000,
    num_customers: int = 300_000,
    num_rides: int = 2_000_000,
    batch_size: int = 10_000
) -> None:


    connection = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database
    )
    cursor = connection.cursor()

    fake = Faker()

    # ---- Drivers ----
    print("Inserting drivers...")
    insert_driver_query = "INSERT INTO drivers (id, name, region) VALUES (%s, %s, %s)"
    for i in range(0, num_drivers, batch_size):
        batch = [generate_driver_record(fake) for _ in range(batch_size)]
        cursor.executemany(insert_driver_query, batch)
        connection.commit()
        print(f"Inserted {min(i + batch_size, num_drivers)} / {num_drivers} drivers")

    # ---- Costumers ----
    print("👥 Inserting customers...")
    insert_customer_query = "INSERT INTO customers (id, name, city) VALUES (%s, %s, %s)"
    for i in range(0, num_customers, batch_size):
        batch = [generate_customer_record(fake) for _ in range(batch_size)]
        cursor.executemany(insert_customer_query, batch)
        connection.commit()
        print(f"Inserted {min(i + batch_size, num_customers)} / {num_customers} customers")


    print("Fetching driver and customer IDs...")
    cursor.execute("SELECT id FROM drivers")
    driver_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT id FROM customers")
    customer_ids = [row[0] for row in cursor.fetchall()]

    # ---- Rides ----
    print("Inserting rides...")
    insert_ride_query = """
        INSERT INTO rides (id, driver_id, customer_id, distance_km, price, ride_date)
        VALUES (%s, %s, %s, %s, %s, %s)
    """
    for i in range(0, num_rides, batch_size):
        batch = [generate_ride_record(driver_ids, customer_ids, fake) for _ in range(batch_size)]
        cursor.executemany(insert_ride_query, batch)
        connection.commit()
        print(f"Inserted {min(i + batch_size, num_rides)} / {num_rides} rides")

    cursor.close()
    connection.close()
    print("Data generation complete!")


if __name__ == "__main__":
    insert_taxi_data(
        host="127.0.0.1",
        user="root",
        password="MySQL_Student123",
        database="taxi",
        num_drivers=100_000,
        num_customers=100_000,
        num_rides=100_000,
        batch_size=100_000
    )


