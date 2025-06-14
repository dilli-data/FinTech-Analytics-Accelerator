with login_activity as (
    select * from {{ ref('stg_login_activity') }}
),

fraud_indicators as (
    select * from {{ ref('fraud_indicators') }}
),

security_metrics as (
    select
        l.customer_id,
        date_trunc('day', l.login_timestamp) as activity_date,
        -- Login metrics
        count(*) as total_login_attempts,
        sum(case when l.is_failed_login then 1 else 0 end) as failed_login_attempts,
        sum(case when l.is_external_ip then 1 else 0 end) as external_ip_logins,
        sum(case when l.is_foreign_location then 1 else 0 end) as foreign_location_logins,
        -- Device metrics
        count(distinct l.device_fingerprint) as unique_devices,
        -- Fraud metrics
        sum(case when f.is_fraudulent then 1 else 0 end) as fraudulent_transactions,
        sum(case when f.is_high_value then 1 else 0 end) as high_value_transactions,
        -- Risk scoring
        case 
            when sum(case when l.is_failed_login then 1 else 0 end) > 3 then 50
            when sum(case when l.is_external_ip then 1 else 0 end) > 2 then 30
            when sum(case when l.is_foreign_location then 1 else 0 end) > 1 then 20
            else 0
        end +
        case 
            when count(distinct l.device_fingerprint) > 3 then 20
            else 0
        end +
        case 
            when sum(case when f.is_fraudulent then 1 else 0 end) > 0 then 100
            when sum(case when f.is_high_value then 1 else 0 end) > 2 then 30
            else 0
        end as security_risk_score
    from login_activity l
    left join fraud_indicators f
        on l.customer_id = f.customer_id
        and date_trunc('day', l.login_timestamp) = date_trunc('day', f.transaction_date)
    group by 1, 2
)

select 
    *,
    case 
        when security_risk_score >= 100 then 'Critical'
        when security_risk_score >= 70 then 'High'
        when security_risk_score >= 40 then 'Medium'
        else 'Low'
    end as security_risk_level,
    -- Additional metrics
    round(failed_login_attempts::float / nullif(total_login_attempts, 0) * 100, 2) as failed_login_rate,
    round(external_ip_logins::float / nullif(total_login_attempts, 0) * 100, 2) as external_ip_rate
from security_metrics
order by activity_date desc, security_risk_score desc 