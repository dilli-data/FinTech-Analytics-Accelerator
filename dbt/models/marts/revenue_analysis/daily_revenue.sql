with transactions as (
    select * from {{ ref('stg_transactions') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

daily_revenue as (
    select
        date_trunc('day', transaction_date) as transaction_date,
        -- Revenue by transaction type
        sum(case when transaction_type = 'purchase' then amount * 0.02 end) as interchange_fees,
        sum(case when transaction_type = 'transfer' then amount * 0.01 end) as transfer_fees,
        sum(case when transaction_type = 'withdrawal' then amount * 0.015 end) as withdrawal_fees,
        -- Revenue by customer tier
        sum(case 
            when c.customer_tier = 'Premium' then amount * 0.02
            when c.customer_tier = 'Standard' then amount * 0.015
            else amount * 0.01
        end) as tier_based_fees,
        -- Transaction counts
        count(*) as total_transactions,
        count(distinct customer_id) as unique_customers,
        -- Average transaction value
        avg(amount) as avg_transaction_value,
        -- High-value transaction count
        count(case when amount > 1000 then 1 end) as high_value_transactions
    from transactions t
    left join customers c
        on t.customer_id = c.customer_id
    where status = 'completed'
    group by 1
)

select 
    *,
    interchange_fees + transfer_fees + withdrawal_fees as total_fees,
    round((interchange_fees + transfer_fees + withdrawal_fees) / total_transactions, 2) as avg_fee_per_transaction
from daily_revenue
order by transaction_date desc 