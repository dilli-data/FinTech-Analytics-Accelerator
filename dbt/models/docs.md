# FinTech Analytics Models Documentation

## Staging Models

### stg_login_activity
This model processes raw login activity data and adds security-focused transformations.

**Key Features:**
- Failed login detection
- External IP detection
- Device fingerprinting
- Geographic anomaly detection

**Key Fields:**
- `login_id`: Unique identifier for each login attempt
- `customer_id`: Customer identifier
- `login_timestamp`: Timestamp of the login attempt
- `is_failed_login`: Boolean flag for failed login attempts
- `is_external_ip`: Boolean flag for non-internal IP addresses
- `device_fingerprint`: Unique device identifier
- `is_foreign_location`: Boolean flag for non-US locations

### stg_credit_scores
This model processes credit score data and adds risk assessment transformations.

**Key Features:**
- Credit rating categorization
- Risk score calculation
- Score trend analysis

**Key Fields:**
- `score_id`: Unique identifier for each credit score record
- `customer_id`: Customer identifier
- `credit_score`: Numerical credit score (300-850)
- `credit_rating`: Categorized rating (Excellent/Good/Fair/Poor)
- `risk_score`: Calculated risk score based on multiple factors
- `score_trend`: Score movement direction (Improving/Declining/Stable)

## Mart Models

### security_monitoring
This model combines login activity and fraud indicators for comprehensive security analysis.

**Key Features:**
- Daily security metrics
- Risk scoring
- Login attempt analysis
- Device usage patterns

**Key Fields:**
- `customer_id`: Customer identifier
- `activity_date`: Date of activity
- `total_login_attempts`: Total number of login attempts
- `failed_login_attempts`: Number of failed login attempts
- `external_ip_logins`: Number of logins from external IPs
- `foreign_location_logins`: Number of logins from foreign locations
- `unique_devices`: Number of unique devices used
- `security_risk_score`: Calculated security risk score
- `security_risk_level`: Risk level categorization (Critical/High/Medium/Low)
- `failed_login_rate`: Percentage of failed login attempts
- `external_ip_rate`: Percentage of external IP logins

### customer_risk_profile
This model creates a holistic risk profile by combining credit scores, transaction behavior, and security metrics.

**Key Features:**
- Comprehensive risk assessment
- Customer tiering
- Fraud rate calculation
- Transaction pattern analysis

**Key Fields:**
- `customer_id`: Customer identifier
- `credit_score`: Numerical credit score
- `credit_rating`: Credit rating category
- `credit_risk_score`: Risk score from credit data
- `score_trend`: Credit score trend
- `total_transactions`: Total number of transactions
- `fraudulent_transactions`: Number of fraudulent transactions
- `avg_transaction_amount`: Average transaction amount
- `max_transaction_amount`: Maximum transaction amount
- `max_security_risk`: Highest security risk score
- `max_failed_logins`: Maximum number of failed logins
- `combined_risk_score`: Overall risk score
- `overall_risk_level`: Risk level categorization
- `fraud_rate`: Percentage of fraudulent transactions
- `risk_adjusted_tier`: Customer tier based on risk and credit score

## Data Quality Tests

### Schema Tests
- Unique constraints on primary keys
- Not null constraints on required fields
- Referential integrity with customer data
- Value range validations for scores and rates

### Custom Tests
- Risk score categorization validation
- Customer tiering logic validation
- Fraud rate calculation validation

## Usage Guidelines

### Security Monitoring
1. Monitor daily security metrics for unusual patterns
2. Review high-risk customers regularly
3. Investigate multiple failed login attempts
4. Track device usage patterns

### Risk Profiling
1. Use risk-adjusted tiers for customer segmentation
2. Monitor credit score trends
3. Track fraud rates by customer segment
4. Review high-value transactions

### Best Practices
1. Run tests before deploying model changes
2. Monitor data quality metrics
3. Review security alerts daily
4. Update risk scoring parameters as needed 