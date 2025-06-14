with transactions as (
    select * from {{ ref('stg_transactions') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

fraud_indicators as (
    select
        t.transaction_id,
        t.customer_id,
        t.amount,
        t.merchant_name,
        t.transaction_date,
        t.device_id,
        t.ip_address,
        t.is_fraudulent,
        c.risk_level as customer_risk_level,
        -- High-value transaction flag
        case 
            when t.amount > 1000 then true
            else false
        end as is_high_value,
        -- Multiple transactions in short time
        case 
            when count(*) over (
                partition by t.customer_id 
                order by t.transaction_date 
                range between interval '1 hour' preceding and current row
            ) > 3 then true
            else false
        end as has_rapid_transactions,
        -- Unusual merchant category
        case 
            when t.merchant_category in ('electronics', 'travel') 
            and c.income_level = 'low' then true
            else false
        end as has_unusual_merchant,
        -- Risk score calculation
        case 
            when t.is_fraudulent then 100
            when t.amount > 1000 then 50
            when c.risk_level = 'high' then 30
            else 0
        end as fraud_risk_score
    from transactions t
    left join customers c
        on t.customer_id = c.customer_id
)

select 
    *,
    case 
        when fraud_risk_score >= 80 then 'Critical'
        when fraud_risk_score >= 50 then 'High'
        when fraud_risk_score >= 30 then 'Medium'
        else 'Low'
    end as risk_category
from fraud_indicators 