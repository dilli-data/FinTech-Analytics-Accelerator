with source as (
    select * from {{ source('raw', 'login_activity') }}
),

renamed as (
    select
        login_id,
        customer_id,
        login_timestamp,
        ip_address,
        device_id,
        device_type,
        browser,
        os,
        login_status,
        failure_reason,
        location_country,
        location_city,
        -- Add derived fields
        case 
            when login_status = 'failed' then true
            else false
        end as is_failed_login,
        -- Detect potential VPN usage
        case 
            when ip_address not like '192.168.%' then true
            else false
        end as is_external_ip,
        -- Device fingerprint
        concat(device_type, '_', browser, '_', os) as device_fingerprint,
        -- Location anomaly
        case 
            when location_country != 'USA' then true
            else false
        end as is_foreign_location
    from source
)

select * from renamed 