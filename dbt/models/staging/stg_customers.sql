with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        address,
        city,
        state,
        zip_code,
        country,
        income_level,
        occupation,
        account_created_date,
        kyc_status,
        risk_level,
        -- Add derived fields
        concat(first_name, ' ', last_name) as full_name,
        case 
            when income_level = 'high' then 'Premium'
            when income_level = 'medium' then 'Standard'
            else 'Basic'
        end as customer_tier,
        -- Add data quality checks
        case 
            when email is null then false
            when email not like '%@%.%' then false
            else true
        end as is_valid_email
    from source
)

select * from renamed 