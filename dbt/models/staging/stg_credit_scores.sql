with source as (
    select * from {{ source('raw', 'credit_scores') }}
),

renamed as (
    select
        score_id,
        customer_id,
        score_date,
        credit_score,
        score_change,
        payment_history,
        credit_utilization,
        credit_age,
        recent_inquiries,
        debt_to_income,
        risk_factors,
        -- Add derived fields
        case 
            when credit_score >= 750 then 'Excellent'
            when credit_score >= 700 then 'Good'
            when credit_score >= 650 then 'Fair'
            else 'Poor'
        end as credit_rating,
        -- Calculate risk score
        case 
            when payment_history = 'excellent' then 0
            when payment_history = 'good' then 10
            when payment_history = 'fair' then 20
            else 30
        end +
        case 
            when credit_utilization <= 0.3 then 0
            when credit_utilization <= 0.5 then 10
            else 20
        end +
        case 
            when recent_inquiries <= 1 then 0
            when recent_inquiries <= 3 then 10
            else 20
        end as risk_score,
        -- Trend analysis
        case 
            when score_change > 0 then 'Improving'
            when score_change < 0 then 'Declining'
            else 'Stable'
        end as score_trend
    from source
)

select * from renamed 