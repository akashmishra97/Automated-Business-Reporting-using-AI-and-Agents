-- Siemens Energy Bid Management Database Schema
-- This file contains all tables and sample data for the bid management system

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. BIDS TABLE - Main bid information
CREATE TABLE bids (
    bid_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_name VARCHAR(255) NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    bid_value DECIMAL(15,2) NOT NULL CHECK (bid_value > 0),
    estimated_cost DECIMAL(15,2) NOT NULL CHECK (estimated_cost > 0),
    actual_cost_to_date DECIMAL(15,2) DEFAULT 0 CHECK (actual_cost_to_date >= 0),
    win_probability INTEGER CHECK (win_probability >= 0 AND win_probability <= 100),
    bid_status VARCHAR(50) CHECK (bid_status IN ('Active', 'In Progress', 'Under Review', 'Submitted', 'Won', 'Lost', 'Cancelled')),
    submission_deadline DATE NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bid_stage VARCHAR(100) CHECK (bid_stage IN ('Opportunity Identification', 'Qualification', 'Proposal Development', 'Review', 'Submission', 'Evaluation', 'Award')),
    team_lead VARCHAR(255) NOT NULL,
    risk_level VARCHAR(20) CHECK (risk_level IN ('Low', 'Medium', 'High', 'Critical')),
    compliance_status VARCHAR(50) DEFAULT 'Pending',
    project_type VARCHAR(100),
    sector VARCHAR(100),
    region VARCHAR(100),
    description TEXT
);

-- 2. BID_PROGRESS TABLE - Milestone tracking
CREATE TABLE bid_progress (
    progress_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id UUID REFERENCES bids(bid_id) ON DELETE CASCADE,
    milestone_name VARCHAR(255) NOT NULL,
    milestone_status VARCHAR(50) DEFAULT 'Pending' CHECK (milestone_status IN ('Pending', 'In Progress', 'Completed', 'Delayed')),
    due_date DATE NOT NULL,
    completed_date DATE,
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    days_remaining INTEGER,
    next_milestone VARCHAR(255),
    milestone_due_date DATE,
    notes TEXT
);

-- 3. BID_RISKS TABLE - Risk assessment and mitigation
CREATE TABLE bid_risks (
    risk_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id UUID REFERENCES bids(bid_id) ON DELETE CASCADE,
    risk_type VARCHAR(100) NOT NULL,
    risk_description TEXT NOT NULL,
    impact_level VARCHAR(20) CHECK (impact_level IN ('Low', 'Medium', 'High', 'Critical')),
    probability VARCHAR(20) CHECK (probability IN ('Low', 'Medium', 'High')),
    mitigation_status VARCHAR(50) DEFAULT 'Not Started' CHECK (mitigation_status IN ('Not Started', 'In Progress', 'Completed', 'On Hold')),
    mitigation_actions TEXT,
    assigned_to VARCHAR(255),
    due_date DATE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. TEAM_MEMBERS TABLE - Bid team information
CREATE TABLE team_members (
    team_member_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_member_name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    skills TEXT,
    current_workload_percent INTEGER DEFAULT 0 CHECK (current_workload_percent >= 0 AND current_workload_percent <= 100),
    available_capacity INTEGER DEFAULT 100 CHECK (available_capacity >= 0 AND available_capacity <= 100),
    availability_status VARCHAR(50) DEFAULT 'Available' CHECK (availability_status IN ('Available', 'Limited', 'Unavailable', 'On Leave')),
    bid_manager VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    department VARCHAR(100)
);

-- 5. BID_TEAM_ASSIGNMENTS TABLE - Team member assignments to bids
CREATE TABLE bid_team_assignments (
    assignment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id UUID REFERENCES bids(bid_id) ON DELETE CASCADE,
    team_member_id UUID REFERENCES team_members(team_member_id) ON DELETE CASCADE,
    role_in_bid VARCHAR(100),
    hours_allocated INTEGER CHECK (hours_allocated > 0),
    start_date DATE,
    end_date DATE,
    assignment_status VARCHAR(50) DEFAULT 'Active' CHECK (assignment_status IN ('Active', 'Completed', 'Cancelled')),
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 6. BID_COSTS TABLE - Detailed cost tracking
CREATE TABLE bid_costs (
    cost_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id UUID REFERENCES bids(bid_id) ON DELETE CASCADE,
    cost_category VARCHAR(100) NOT NULL,
    estimated_amount DECIMAL(15,2) NOT NULL CHECK (estimated_amount > 0),
    actual_amount DECIMAL(15,2) DEFAULT 0 CHECK (actual_amount >= 0),
    variance DECIMAL(15,2) GENERATED ALWAYS AS (actual_amount - estimated_amount) STORED,
    variance_percentage DECIMAL(5,2) GENERATED ALWAYS AS (CASE WHEN estimated_amount > 0 THEN ((actual_amount - estimated_amount) / estimated_amount * 100) ELSE 0 END) STORED,
    cost_date DATE,
    description TEXT
);

-- 7. BID_WIN_LOSS TABLE - Historical bid outcomes
CREATE TABLE bid_win_loss (
    outcome_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id UUID REFERENCES bids(bid_id) ON DELETE CASCADE,
    outcome VARCHAR(20) CHECK (outcome IN ('Won', 'Lost', 'Cancelled')),
    award_date DATE,
    final_value DECIMAL(15,2) CHECK (final_value > 0),
    final_cost DECIMAL(15,2) CHECK (final_cost > 0),
    profit_margin DECIMAL(5,2) CHECK (profit_margin >= -100 AND profit_margin <= 100),
    win_factors TEXT,
    loss_reasons TEXT,
    lessons_learned TEXT,
    competitor_analysis TEXT
);

-- 8. BID_COMPLIANCE TABLE - Compliance tracking
CREATE TABLE bid_compliance (
    compliance_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id UUID REFERENCES bids(bid_id) ON DELETE CASCADE,
    compliance_requirement VARCHAR(255) NOT NULL,
    requirement_type VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Completed', 'Failed')),
    due_date DATE,
    completed_date DATE,
    responsible_party VARCHAR(255),
    documentation_url TEXT,
    notes TEXT
);

-- Sample Data (Sanitized)
INSERT INTO bids (bid_name, client_name, bid_value, estimated_cost, actual_cost_to_date, win_probability, bid_status, submission_deadline, bid_stage, team_lead, risk_level, compliance_status, project_type, sector, region) VALUES
('Offshore Wind Farm Phase 2', 'North Sea Energy Corp', 45000000.00, 38000000.00, 8500000.00, 85, 'Active', '2024-02-15', 'Proposal Development', 'Bid Manager 1', 'Medium', 'Compliant', 'Renewable Energy', 'Wind Power', 'Europe'),
('Grid Modernization Project', 'European Power Grid', 28000000.00, 22000000.00, 3200000.00, 75, 'In Progress', '2024-01-30', 'Review', 'Bid Manager 1', 'Low', 'Compliant', 'Grid Infrastructure', 'Transmission', 'Europe'),
('Solar Power Plant Expansion', 'Green Energy Solutions', 32000000.00, 26500000.00, 0.00, 60, 'Active', '2024-03-10', 'Qualification', 'Bid Manager 1', 'High', 'Pending', 'Renewable Energy', 'Solar Power', 'Asia'),
('Hydroelectric Dam Upgrade', 'River Power Authority', 65000000.00, 52000000.00, 12000000.00, 90, 'Under Review', '2024-01-20', 'Submission', 'Bid Manager 1', 'Medium', 'Compliant', 'Hydroelectric', 'Water Power', 'North America');

-- Create indexes for performance
CREATE INDEX idx_bids_team_lead ON bids(team_lead);
CREATE INDEX idx_bids_status ON bids(bid_status);
CREATE INDEX idx_bids_deadline ON bids(submission_deadline);
CREATE INDEX idx_bid_progress_bid_id ON bid_progress(bid_id);
CREATE INDEX idx_bid_risks_bid_id ON bid_risks(bid_id);
CREATE INDEX idx_team_members_bid_manager ON team_members(bid_manager);
CREATE INDEX idx_bid_team_assignments_bid_id ON bid_team_assignments(bid_id);
CREATE INDEX idx_bid_costs_bid_id ON bid_costs(bid_id);

-- Create useful views
CREATE VIEW active_bids_summary AS
SELECT 
    bid_id,
    bid_name,
    client_name,
    bid_value,
    estimated_cost,
    win_probability,
    bid_status,
    submission_deadline,
    team_lead
FROM bids 
WHERE bid_status IN ('Active', 'In Progress', 'Under Review');

CREATE VIEW bid_pipeline_status AS
SELECT 
    bid_stage,
    COUNT(*) as bid_count,
    SUM(bid_value) as total_value,
    AVG(win_probability) as avg_win_probability
FROM bids 
WHERE bid_status IN ('Active', 'In Progress', 'Under Review')
GROUP BY bid_stage;

CREATE VIEW team_workload_summary AS
SELECT 
    bid_manager,
    COUNT(*) as active_bids,
    SUM(bid_value) as total_pipeline_value,
    AVG(win_probability) as avg_win_probability
FROM bids 
WHERE bid_status IN ('Active', 'In Progress', 'Under Review')
GROUP BY bid_manager; 