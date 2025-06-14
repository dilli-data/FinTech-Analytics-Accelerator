-- Test that security risk scores are properly categorized
with security_risk_test as (
    select 
        security_risk_score,
        security_risk_level
    from {{ ref('security_monitoring') }}
)

select *
from security_risk_test
where not (
    (security_risk_score >= 100 and security_risk_level = 'Critical') or
    (security_risk_score >= 70 and security_risk_score < 100 and security_risk_level = 'High') or
    (security_risk_score >= 40 and security_risk_score < 70 and security_risk_level = 'Medium') or
    (security_risk_score < 40 and security_risk_level = 'Low')
)

-- Test that customer risk profiles are properly tiered
with customer_risk_test as (
    select 
        credit_rating,
        overall_risk_level,
        risk_adjusted_tier
    from {{ ref('customer_risk_profile') }}
)

select *
from customer_risk_test
where not (
    (credit_rating = 'Excellent' and overall_risk_level = 'Low' and risk_adjusted_tier = 'Premium') or
    (credit_rating in ('Good', 'Excellent') and overall_risk_level in ('Low', 'Medium') and risk_adjusted_tier = 'Standard') or
    (risk_adjusted_tier = 'Basic')
)

-- Test that fraud rates are properly calculated
with fraud_rate_test as (
    select 
        fraudulent_transactions,
        total_transactions,
        fraud_rate
    from {{ ref('customer_risk_profile') }}
    where total_transactions > 0
)

select *
from fraud_rate_test
where not (
    round(fraudulent_transactions::float / total_transactions * 100, 2) = fraud_rate
) 