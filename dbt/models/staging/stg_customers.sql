with source as (
    select * from {{ source('raw', 'customers') }}
),

staged as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        phone_number,
        date_of_birth,
        address,
        city,
        state,
        zip_code,
        country,
        created_at,
        updated_at
    from source
)

select * from staged 