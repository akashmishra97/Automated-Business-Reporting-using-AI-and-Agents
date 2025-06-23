# Setup Guide - Siemens Energy Bid Management Intelligence System

This guide provides step-by-step instructions for setting up the automated bid management intelligence system.

## Prerequisites

Before beginning the setup, ensure you have:

1. **n8n Instance**: Either self-hosted or cloud-based n8n instance
2. **PostgreSQL Database**: Access to a PostgreSQL database (version 12 or higher)
3. **Google Gemini API**: Active Google Gemini API account with API key
4. **Email Service**: Gmail or Microsoft Outlook account for report delivery
5. **Network Access**: Ability to connect n8n to your database and external APIs

## Step 1: Database Setup

### 1.1 Create Database
```sql
-- Connect to your PostgreSQL instance
CREATE DATABASE siemens_bid_management;
```

### 1.2 Execute Schema
```bash
# Execute the database schema file
psql -d siemens_bid_management -f database_schema.sql
```

### 1.3 Verify Setup
```sql
-- Connect to the database and verify tables
\dt

-- Check sample data
SELECT COUNT(*) FROM bids;
SELECT COUNT(*) FROM team_members;
```

## Step 2: n8n Configuration

### 2.1 Access n8n
1. Open your n8n instance in a web browser
2. Log in with your credentials
3. Navigate to the workflows section

### 2.2 Import Workflow
1. Click "Import from file" or "Import workflow"
2. Select the `workflow_sanitized.json` file
3. Review the imported workflow structure
4. Save the workflow with a descriptive name

### 2.3 Configure Credentials

#### PostgreSQL Credentials
1. Go to Settings > Credentials
2. Click "Add Credential"
3. Select "PostgreSQL"
4. Configure with your database details:
   - Host: Your PostgreSQL server address
   - Database: siemens_bid_management
   - User: Your database username
   - Password: Your database password
   - Port: 5432 (default)
5. Test the connection
6. Save the credential and note the credential ID

#### Google Gemini API Credentials
1. Go to Settings > Credentials
2. Click "Add Credential"
3. Select "Google Gemini API"
4. Enter your API key from Google AI Studio
5. Test the connection
6. Save the credential and note the credential ID

#### Email Credentials
1. Go to Settings > Credentials
2. Click "Add Credential"
3. Select "Gmail" or "Microsoft Outlook"
4. Follow the OAuth2 authentication process
5. Test the connection
6. Save the credential and note the credential ID

### 2.4 Update Workflow Credentials
1. Open the imported workflow
2. For each node that requires credentials:
   - Click on the node
   - In the credentials section, select your configured credential
   - Save the node configuration

### 2.5 Configure Email Recipients
1. Find the Gmail/Outlook nodes in the workflow
2. Update the "To" field with actual email addresses
3. Customize the email subject line if needed
4. Test the email configuration

## Step 3: Data Population

### 3.1 Add Sample Data
The database schema includes sample data, but you may want to add more:

```sql
-- Add additional sample bids
INSERT INTO bids (bid_name, client_name, bid_value, estimated_cost, actual_cost_to_date, win_probability, bid_status, submission_deadline, bid_stage, team_lead, risk_level, compliance_status, project_type, sector, region) VALUES
('Smart Grid Implementation', 'City Power Utilities', 18000000.00, 14500000.00, 2800000.00, 70, 'Active', '2024-02-28', 'Proposal Development', 'Bid Manager 1', 'Low', 'Compliant', 'Smart Grid', 'Distribution', 'Europe'),
('Nuclear Plant Safety Systems', 'Atomic Energy Corp', 85000000.00, 68000000.00, 15000000.00, 80, 'In Progress', '2024-03-15', 'Review', 'Bid Manager 1', 'Critical', 'Compliant', 'Nuclear', 'Nuclear Power', 'Europe');

-- Add team members
INSERT INTO team_members (team_member_name, role, skills, current_workload_percent, available_capacity, availability_status, bid_manager, email, phone, department) VALUES
('Technical Lead 1', 'Technical Lead', 'Power Systems, Grid Infrastructure, Renewable Energy', 90, 10, 'Limited', 'Bid Manager 1', 'tech.lead@company.com', '+1-555-0102', 'Engineering'),
('Risk Manager 1', 'Risk Manager', 'Risk Assessment, Compliance, Nuclear Safety', 70, 30, 'Available', 'Bid Manager 1', 'risk.manager@company.com', '+1-555-0103', 'Risk Management'),
('Financial Analyst 1', 'Financial Analyst', 'Cost Estimation, Financial Modeling, Budget Management', 75, 25, 'Available', 'Bid Manager 1', 'finance.analyst@company.com', '+1-555-0104', 'Finance');
```

### 3.2 Verify Data Integrity
```sql
-- Check data relationships
SELECT 
    b.bid_name,
    COUNT(bp.progress_id) as milestones,
    COUNT(br.risk_id) as risks,
    COUNT(tm.team_member_id) as team_members
FROM bids b
LEFT JOIN bid_progress bp ON b.bid_id = bp.bid_id
LEFT JOIN bid_risks br ON b.bid_id = br.bid_id
LEFT JOIN team_members tm ON b.team_lead = tm.bid_manager
GROUP BY b.bid_id, b.bid_name;
```

## Step 4: Workflow Testing

### 4.1 Manual Execution
1. In n8n, click on the workflow
2. Click "Execute Workflow" to run it manually
3. Monitor the execution in real-time
4. Check for any errors in the execution log

### 4.2 Verify Output
1. Check your email for the generated report
2. Verify the report contains all expected sections
3. Confirm data accuracy in the report
4. Test with different bid managers if configured

### 4.3 Debug Common Issues
- **Database Connection**: Verify PostgreSQL credentials and network connectivity
- **AI API**: Check Gemini API key validity and rate limits
- **Email Delivery**: Ensure email credentials are properly configured
- **Data Quality**: Verify database contains the expected data

## Step 5: Production Deployment

### 5.1 Schedule Configuration
1. In the workflow, find the "Weekly Schedule Trigger" node
2. Configure the schedule to run at your preferred time
3. Set the timezone appropriately
4. Test the schedule with a shorter interval first

### 5.2 Monitoring Setup
1. Configure n8n notifications for workflow failures
2. Set up logging for workflow execution
3. Monitor email delivery success rates
4. Track AI API usage and costs

### 5.3 Security Hardening
1. Use environment variables for all sensitive data
2. Implement proper database access controls
3. Configure firewall rules for database access
4. Regular credential rotation

## Step 6: Customization

### 6.1 Report Customization
1. Modify the HTML template in the "Code" node
2. Update Siemens Energy branding and colors
3. Add or remove report sections as needed
4. Customize email subject lines and recipients

### 6.2 Data Source Integration
1. Add additional database queries for new metrics
2. Integrate with external APIs for market data
3. Connect to CRM systems for customer information
4. Link with project management tools

### 6.3 AI Enhancement
1. Customize the AI prompt for specific analysis needs
2. Add additional tools to the AI agent
3. Implement custom calculations and metrics
4. Enhance risk assessment algorithms

## Troubleshooting

### Common Issues and Solutions

#### Database Connection Issues
```bash
# Test database connectivity
psql -h your_host -U your_user -d siemens_bid_management -c "SELECT 1;"
```

#### AI API Issues
- Verify API key is valid and has sufficient quota
- Check rate limits and implement retry logic
- Monitor API response times and errors

#### Email Delivery Issues
- Verify email credentials and permissions
- Check spam filters and email server settings
- Test with different email providers

#### Workflow Execution Issues
- Check n8n logs for detailed error messages
- Verify all credentials are properly configured
- Test individual nodes for functionality

## Support and Maintenance

### Regular Maintenance Tasks
1. **Weekly**: Monitor workflow execution and email delivery
2. **Monthly**: Review AI analysis quality and update prompts
3. **Quarterly**: Optimize database queries and indexes
4. **Annually**: Update system documentation and procedures

### Performance Optimization
1. Monitor database query performance
2. Optimize workflow execution time
3. Review AI API usage and costs
4. Scale system resources as needed

### Security Updates
1. Regular credential rotation
2. Database security patches
3. n8n version updates
4. API key management

## Next Steps

After successful setup:

1. **User Training**: Train bid managers on interpreting reports
2. **Process Integration**: Integrate reports into existing business processes
3. **Feedback Collection**: Gather user feedback for system improvements
4. **System Expansion**: Plan for additional features and integrations

For additional support or questions, refer to the main README.md file or contact the system development team. 