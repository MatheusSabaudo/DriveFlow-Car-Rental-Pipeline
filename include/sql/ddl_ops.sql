# SCHEMA CREATION - OPS (TASK A1.2)
CREATE SCHEMA IF NOT EXISTS ops;

# TABLE CREATION - OPS (TASK A1.3)

CREATE TABLE IF NOT EXISTS ops.vehicle (
    vehicle_id BIGINT PRIMARY KEY,
    vin BIGINT NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    fuel_type VARCHAR(50) NOT NULL,
    acquisition_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ops.branch (
    branch_id BIGINT PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ops.customer (
    customer_id BIGINT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    country VARCHAR(100) NOT NULL,
    signup_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ops.rental (
    rental_id BIGINT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL REFERENCES ops.vehicle(vehicle_id),
    customer_id BIGINT NOT NULL REFERENCES ops.customer(customer_id),
    pickup_branch_id BIGINT NOT NULL REFERENCES ops.branch(branch_id),
    return_branch_id BIGINT NOT NULL REFERENCES ops.branch(branch_id),
    start_ts DATE NOT NULL,
    end_ts DATE NOT NULL,
    daily_rate_eur DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ops.odometer (
    reading_id BIGINT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL REFERENCES ops.vehicle(vehicle_id),
    rental_id BIGINT NOT NULL REFERENCES ops.rental(rental_id),
    ts TIMESTAMP NOT NULL,
    odometer_reading_km DECIMAL(10,2) NOT NULL,
    fuel_level_percentage DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);