-- Create database
CREATE DATABASE fintech_db;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;

-- Create raw tables
CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    processed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES raw.customers(customer_id),
    transaction_date TIMESTAMP,
    amount DECIMAL(18,2),
    currency VARCHAR(3),
    transaction_type VARCHAR(50),
    merchant_name VARCHAR(255),
    merchant_category VARCHAR(100),
    status VARCHAR(50),
    processed_at TIMESTAMP
);

-- Create staging views
CREATE OR REPLACE VIEW staging.stg_customers AS
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    date_of_birth,
    address,
    city,
    state,
    zip_code,
    country,
    created_at,
    updated_at
FROM raw.customers;

CREATE OR REPLACE VIEW staging.stg_transactions AS
SELECT
    transaction_id,
    customer_id,
    transaction_date,
    amount,
    currency,
    transaction_type,
    merchant_name,
    merchant_category,
    status
FROM raw.transactions;

-- Create mart tables
CREATE TABLE IF NOT EXISTS marts.customer_transactions (
    customer_id VARCHAR(50),
    transaction_date DATE,
    total_transactions INTEGER,
    total_amount DECIMAL(18,2),
    avg_transaction_amount DECIMAL(18,2),
    last_transaction_date TIMESTAMP,
    PRIMARY KEY (customer_id, transaction_date)
);

-- Create indexes
CREATE INDEX idx_customers_email ON raw.customers(email);
CREATE INDEX idx_transactions_customer_id ON raw.transactions(customer_id);
CREATE INDEX idx_transactions_date ON raw.transactions(transaction_date);

-- Create users and permissions
CREATE USER etl_user WITH PASSWORD 'your_secure_password';
CREATE USER analyst_user WITH PASSWORD 'your_secure_password';

-- Grant permissions
GRANT USAGE ON SCHEMA raw TO etl_user;
GRANT USAGE ON SCHEMA staging TO etl_user;
GRANT USAGE ON SCHEMA marts TO etl_user;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA raw TO etl_user;
GRANT SELECT ON ALL TABLES IN SCHEMA staging TO etl_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA marts TO etl_user;

GRANT USAGE ON SCHEMA staging TO analyst_user;
GRANT USAGE ON SCHEMA marts TO analyst_user;
GRANT SELECT ON ALL TABLES IN SCHEMA staging TO analyst_user;
GRANT SELECT ON ALL TABLES IN SCHEMA marts TO analyst_user; 