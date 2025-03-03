{{
    config(
        materialized='incremental'
    )
}}

with source as (

    select * from {{ source('user_engagement', 'web_events') }}

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
        cast(arrival_timestamp as timestamp) as arrival_timestamp,

        -- user
        cast(user_id as varchar) as user_id,
        user_access_type,

        -- item
        cast(item_id as varchar) as item_id,
        item_type,
        item_title,

        -- web-specific columns
        -- device
        browser_name,
        cast(browser_version as varchar) as browser_version,
        screen_resolution,
        cookies_enabled,
        device_type,
       
        -- location
        language,
        country_code

    from source
)

select distinct * from renamed
