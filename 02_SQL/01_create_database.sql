-- ============================================
-- Project: US-Iran War Port Impact Analysis
-- File: 01_create_database.sql
-- Purpose: Complete database setup (schema + table + indexes)
-- ============================================

-- NOTE:
-- Run CREATE DATABASE separately first time if not created
-- CREATE DATABASE port_analysis_db;

-- ============================================
-- 1. Create Schema
-- ============================================
CREATE SCHEMA IF NOT EXISTS cargo;

-- ============================================
-- 2. Set Default Schema
-- ============================================
SET search_path TO cargo;

-- ============================================
-- 3. Drop Table (to avoid error if exists)
-- ============================================
DROP TABLE IF EXISTS cargo.port_cargo;

-- ============================================
-- 4. Create Table
-- ============================================
CREATE TABLE cargo.port_cargo (
    id SERIAL PRIMARY KEY,

    port_name VARCHAR(50) NOT NULL,

    flow_type VARCHAR(20) NOT NULL 
        CHECK (flow_type IN ('Incoming', 'Outgoing')),

    transaction_date DATE NOT NULL,

    container INT NOT NULL DEFAULT 0,
    dry_bulk INT NOT NULL DEFAULT 0,
    general_cargo INT NOT NULL DEFAULT 0,
    ro_ro INT NOT NULL DEFAULT 0,
    tanker INT NOT NULL DEFAULT 0,

    total_cargo INT GENERATED ALWAYS AS (
        container + dry_bulk + general_cargo + ro_ro + tanker
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 5. Create Indexes (Performance Optimization)
-- ============================================
CREATE INDEX IF NOT EXISTS idx_date 
ON cargo.port_cargo(transaction_date);

CREATE INDEX IF NOT EXISTS idx_port 
ON cargo.port_cargo(port_name);

CREATE INDEX IF NOT EXISTS idx_flow 
ON cargo.port_cargo(flow_type);

CREATE INDEX IF NOT EXISTS idx_date_port 
ON cargo.port_cargo(transaction_date, port_name);

CREATE INDEX IF NOT EXISTS idx_date_flow 
ON cargo.port_cargo(transaction_date, flow_type);

-- ============================================
-- 6. Verification
-- ============================================
SELECT * FROM cargo.port_cargo LIMIT 0;