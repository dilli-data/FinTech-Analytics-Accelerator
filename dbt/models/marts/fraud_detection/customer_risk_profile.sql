with credit_scores as (
    select * from {{ ref('stg_credit_scores') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

security_metrics as (
    select * from {{ ref('security_monitoring') }}
),

customer_risk as (
    select
        c.customer_id,
        c.credit_score,
        c.credit_rating,
        c.risk_score as credit_risk_score,
        c.score_trend,
        -- Transaction metrics
        count(t.transaction_id) as total_transactions,
        sum(case when t.is_fraudulent then 1 else 0 end) as fraudulent_transactions,
        avg(t.amount) as avg_transaction_amount,
        max(t.amount) as max_transaction_amount,
        -- Security metrics
        max(s.security_risk_score) as max_security_risk,
        max(s.failed_login_attempts) as max_failed_logins,
        -- Combined risk scoring
        c.risk_score + 
        case 
            when count(t.transaction_id) = 0 then 20
            when count(t.transaction_id) < 5 then 10
            else 0
        end +
        case 
            when sum(case when t.is_fraudulent then 1 else 0 end) > 0 then 50
            when avg(t.amount) > 1000 then 20
            else 0
        end +
        case 
            when max(s.security_risk_score) >= 100 then 50
            when max(s.security_risk_score) >= 70 then 30
            when max(s.security_risk_score) >= 40 then 10
            else 0
        end as combined_risk_score
    from credit_scores c
    left join transactions t
        on c.customer_id = t.customer_id
    left join security_metrics s
        on c.customer_id = s.customer_id
    group by 1, 2, 3, 4, 5
)

select 
    *,
    case 
        when combined_risk_score >= 100 then 'Critical'
        when combined_risk_score >= 70 then 'High'
        when combined_risk_score >= 40 then 'Medium'
        else 'Low'
    end as overall_risk_level,
    -- Additional metrics
    round(fraudulent_transactions::float / nullif(total_transactions, 0) * 100, 2) as fraud_rate,
    case 
        when credit_rating = 'Excellent' and overall_risk_level = 'Low' then 'Premium'
        when credit_rating in ('Good', 'Excellent') and overall_risk_level in ('Low', 'Medium') then 'Standard'
        else 'Basic'
    end as risk_adjusted_tier
from customer_risk
order by combined_risk_score desc 