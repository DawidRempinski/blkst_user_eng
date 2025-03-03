{{
    config(
        materialized='incremental'
    )
}}

with source as (

    select * from {{ source('user_engagement', 'mobile_events') }}

    {% if is_incremental() %}

    where event_timestamp > (select max(event_timestamp) from {{ this }})

    {% endif %}

),

renamed as (

    select 

        -- event
        {{ dbt_utils.generate_surrogate_key([
				'event_timestamp', 
				'event_name',
                'user_id',
                'session_id',
                'item_id'
			])
		}} as event_id, 
        event_name as event_type,
        cast(session_id as varchar) as session_id,

        -- dates
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(event_timestamp as timestamp) as arrival_timestamp,

        -- user
        cast(user_id as varchar) as user_id,
        user_access_type,

        -- item
        cast(item_id as varchar) as item_id,
        item_type,
        item_title,

        -- app-specific columns
        -- device
        device_locale_code,
        split_part(device_locale_code, '_', 2) as device_locale_country,
        split_part(device_locale_code, '_', 1) as device_locale_language,
        device_make,
        device_platform_name,
        cast(device_platform_version as varchar) as device_platform_version,
        application_version_name as app_version,

        -- client
        cast(client_id as varchar) as client_id,
        cast(client_cognito_id as varchar) as client_cognito_id

    from source
)

select distinct * from renamed