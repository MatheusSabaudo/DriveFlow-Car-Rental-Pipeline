import random, sys, os
from datetime import datetime, timedelta
from faker import Faker
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values

fake = Faker()
out_root = os.environ.get("RAW_PATH", "data/raw")

# Constants

CATEGORIES = ["economy", "SUV", "luxury", "sports", "sedan", "truck", "hybrid", "electric"]
FUELS = ["gasoline", "diesel", "electric", "hybrid"]
STATUS = ["available", "sold", "maintenance", "reserved", "not available"]

DAILY_RATE_EUR = {
    "economy": 30,
    "SUV": 50,
    "luxury": 130,
    "sports": 150,
    "sedan": 40,
    "truck": 60,
    "hybrid": 45,
    "electric": 55
}

MINIMUM_YEAR = 2016
MAX_YEAR = datetime.now().year

MAKES = ["Toyota", "Ford", "Chevrolet", "Honda", "Nissan", "BMW", "Mercedes-Benz", "Volkswagen", "Audi", "Hyundai"]

MODELS = {
    "Toyota": ["Corolla", "Camry", "RAV4", "Prius", "Highlander"],
    "Ford": ["F-150", "Escape", "Mustang", "Explorer", "Fusion"],
    "Chevrolet": ["Silverado", "Equinox", "Malibu", "Traverse", "Camaro"],
    "Honda": ["Civic", "Accord", "CR-V", "Pilot", "Fit"],
    "Nissan": ["Altima", "Rogue", "Sentra", "Murano", "Maxima"],
    "BMW": ["3 Series", "5 Series", "X3", "X5", "Z4"],
    "Mercedes-Benz": ["C-Class", "E-Class", "GLC", "GLE", "S-Class"],
    "Volkswagen": ["Golf", "Passat", "Tiguan", "Jetta", "Atlas"],
    "Audi": ["A3", "A4", "Q5", "Q7", "A6"],
    "Hyundai": ["Elantra", "Sonata", "Tucson", "Santa Fe", "Kona"]
}

# If a vehicle is returned to a different branch than it was picked up from, a 25 EUR fee is applied
BRANCH_PICKUP_RETURN_COST = 25
PROBABILITY_OF_RETURNING_TO_DIFFERENT_BRANCH = 0.2

VEHICLES_NUM = 200
BRANCHES_NUM = 15
CUSTOMERS_NUM = 1000


# Data Generation Functions

class Vehicle:
    def __init__(self, vehicle_id, vin, make, model, year, category, fuel_type, acquisition_date, status):
        self.vehicle_id = vehicle_id
        self.vin = vin
        self.make = make
        self.model = model
        self.year = year
        self.category = category
        self.fuel_type = fuel_type
        self.acquisition_date = acquisition_date
        self.status = status

    def generate_vehicles(run_date, n=VEHICLES_NUM):
        rows = []
        for i in range(n):

            category = random.choice(CATEGORIES)

            rows.append(dict(
                vehicle_id = f"V{i:05d}",
                vin = fake.unique.bothify("??######??######").upper(),
                make = random.choice(MAKES),
                model = random.choice(MODELS.get(random.choice(MAKES), ["Unknown"])),
                year = random.randint(MINIMUM_YEAR, MAX_YEAR),
                category = category,
                fuel_type = random.choice(FUELS) if category != "electric" else "electric",
                acquisition_date = (run_date - timedelta(days=random.randint(0, 3650))).strftime("%Y-%m-%d"),
                status = random.choice(STATUS)
            ))
        return pd.DataFrame(rows)


class Branch:
    def __init__(self, branch_id, city, country, latitude, longitude):
        self.branch_id = branch_id
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude

    def generate_branches(run_date, n=BRANCHES_NUM):
        rows = []
        for i in range(n):
            rows.append(dict(
                branch_id = f"B{i:05d}",
                city = fake.city(),
                country = fake.country(),
                latitude = fake.latitude(),
                longitude = fake.longitude()
            ))
        return pd.DataFrame(rows)

class Customer:
    def __init__(self, customer_id, first_name, last_name, email, license_number, country, signup_date):
        self.customer_id = customer_id
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.license_number = license_number
        self.country = country
        self.signup_date = signup_date

    def generate_customers(run_date, n=CUSTOMERS_NUM):
        rows = []
        for i in range(n):
            rows.append(dict(
                customer_id = f"C{i:05d}",
                first_name = fake.first_name(),
                last_name = fake.last_name(),
                email = fake.unique.email(),
                license_number = fake.unique.bothify("??######").upper(),
                country = fake.country(),
                signup_date = (run_date - timedelta(days=random.randint(0, 3650))).strftime("%Y-%m-%d")
            ))
        return pd.DataFrame(rows)


class Rental:
    def __init__(self, rental_id, vehicle_id, customer_id, pickup_branch_id, return_branch_id, start_ts, end_ts, daily_rate_eur, status, total_cost_eur):
        self.rental_id = rental_id
        self.vehicle_id = vehicle_id
        self.customer_id = customer_id
        self.pickup_branch_id = pickup_branch_id
        self.return_branch_id = return_branch_id
        self.start_ts = start_ts
        self.end_ts = end_ts
        self.daily_rate_eur = daily_rate_eur
        self.status = status
        self.total_cost_eur = total_cost_eur

    def generate_rentals(vehicles, customers, branches, run_date, n=500):
        rows = []
        for i in range(n):
            vehicle = vehicles.sample(1).iloc[0]
            customer = customers.sample(1).iloc[0]
            pickup_branch = branches.sample(1).iloc[0]

            # Determine if the vehicle is returned to a different branch than it was picked up from
            if random.random() < PROBABILITY_OF_RETURNING_TO_DIFFERENT_BRANCH:
                return_branch = branches[branches["branch_id"] != pickup_branch["branch_id"]].sample(1).iloc[0]
            else:   
                return_branch = pickup_branch


            # Total cost calculation
            total_days = random.randint(1, 30)
            total_cost = total_days * DAILY_RATE_EUR.get(vehicle["category"], 30)

            if pickup_branch["branch_id"] != return_branch["branch_id"]:
                total_cost += BRANCH_PICKUP_RETURN_COST

            rental_start = run_date - timedelta(days=random.randint(0, 365))
            rental_end = rental_start + timedelta(days=random.randint(1, 30))
            
            rows.append(dict(
                rental_id = f"R{run_date.strftime('%Y%m%d')}{i:05d}",
                vehicle_id = vehicle["vehicle_id"],
                customer_id = customer["customer_id"],
                pickup_branch_id = pickup_branch["branch_id"],
                return_branch_id = return_branch["branch_id"],
                start_ts = rental_start.strftime("%Y-%m-%d %H:%M:%S"),  # TS = TIMESTAMP OF THE ODOMETER/FUEL READING BEFORE THE RENTAL START TIME, OR AFTER THE RENTAL END TIME
                end_ts = rental_end.strftime("%Y-%m-%d %H:%M:%S"),      
                daily_rate_eur = DAILY_RATE_EUR.get(vehicle["category"], 30),
                status = "completed" if rental_end < run_date else "ongoing",
                total_cost_eur = total_cost
            ))
        return pd.DataFrame(rows)

class OdometerReading:
    def __init__(self, reading_id, vehicle_id, rental_id, ts, odometer_reading_km, fuel_level_percentage):
        self.reading_id = reading_id
        self.vehicle_id = vehicle_id
        self.rental_id = rental_id
        self.ts = ts
        self.odometer_reading_km = odometer_reading_km
        self.fuel_level_percentage = fuel_level_percentage

    def generate_odometer_readings(vehicles, rentals, run_date):
        rows = []
        for _, rental in rentals.iterrows():
            vehicle = vehicles[vehicles["vehicle_id"] == rental["vehicle_id"]].iloc[0]

            start = datetime.strptime(rental["start_ts"], "%Y-%m-%d %H:%M:%S")
            end = datetime.strptime(rental["end_ts"], "%Y-%m-%d %H:%M:%S")
            span_seconds = max(int((end - start).total_seconds()), 1)

            num_readings = random.randint(2, 6)
            offsets = sorted(random.randint(0, span_seconds) for _ in range(num_readings))

            odometer = random.randint(5_000, 200_000)  # Starting odometer reading in km

            for j, offset in enumerate(offsets):
                ts = start + timedelta(seconds=offset)
                odometer += random.randint(0, 400)  # normal forward movement in km

                reading_km = odometer
                if random.random() < 0.05:  # 5% chance of a rollback
                    reading_km -= random.randint(50, 500)

                fuel = random.randint(0, 100)  # Fuel level percentage
                if random.random() < 0.05:  # 5% chance of a fuel level anomaly
                    fuel = random.choice([random.randint(101, 130), random.randint(-20, -1)])

                rows.append(dict(
                        reading_id = f"O{rental['rental_id'][1:]}_{j}",  
                        vehicle_id = vehicle["vehicle_id"],
                        rental_id = rental["rental_id"],
                        ts = ts.strftime("%Y-%m-%d %H:%M:%S"),          
                        odometer_reading_km = reading_km,
                        fuel_level_percentage = fuel
                    ))
        return pd.DataFrame(rows)


# Upsert helper function

def upsert(conn, table, df, pk):

    df = df.drop(columns=[c for c in ("created_at", "updated_at") if c in df.columns]) # Drop created_at and updated_at columns if they exist
    df = df.where(pd.notnull(df), None) # Place NULLs where there are NaNs

    cols = list(df.columns) # Get the list of columns in the DataFrame
    update_cols = [c for c in cols if c not in pk] # Get the list of columns to update (all columns except the primary key columns)
    set_clause = ", ".join([f"{c} = EXCLUDED.{c}" for c in update_cols]) # Create the SET clause for the ON CONFLICT statement

    # Create the SQL statement for the upsert operation
    sql = f"""
        INSERT INTO {table} ({', '.join(cols)})
        VALUES %s
        ON CONFLICT ({', '.join(pk)}) DO UPDATE SET {set_clause};
    """

    rows = list(df.itertuples(index=False, name=None)) # Convert the DataFrame to a list of tuples for insertion
    
    # Execute the SQL statement using psycopg2's execute_values for efficient bulk insertion
    with conn.cursor() as cur:
        execute_values(cur, sql, rows)

    print(f"Upserted {len(rows)} rows into {table}.")


if __name__ == "__main__":
    run_date_str = sys.argv[1] if len(sys.argv) > 1 else datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    run_date = datetime.strptime(run_date_str, "%Y-%m-%d")

    random.seed(run_date_str)
    Faker.seed(run_date_str)

    vehicles = Vehicle.generate_vehicles(run_date)
    branches = Branch.generate_branches(run_date)
    customers = Customer.generate_customers(run_date)
    rentals = Rental.generate_rentals(vehicles, customers, branches, run_date)
    odometer_readings = OdometerReading.generate_odometer_readings(vehicles, rentals, run_date)

    print(f"Generated {len(vehicles)} vehicles, {len(branches)} branches, {len(customers)} customers, {len(rentals)} rentals, and {len(odometer_readings)} odometer readings.")

    # Connect to the RDS PostgreSQL database and upsert the generated data

    # conn = psycopg2.connect()

    # try:
    #     upsert(conn, "ops.vehicle", vehicles, ["vehicle_id"])
    #     upsert(conn, "ops.branch", branches, ["branch_id"])
    #     upsert(conn, "ops.customer", customers, ["customer_id"])
    #     upsert(conn, "ops.rental", rentals, ["rental_id"])
    #     upsert(conn, "ops.odometer", odometer_readings, ["reading_id"])

    #     conn.commit()
    # except Exception:
    #     conn.rollback()
    #     raise
    # finally:
    #     conn.close()