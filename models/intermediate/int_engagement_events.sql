with web_data as (

    select * from ref('stg_web_events')

),

mobile_data as (

    select * from ref('stg_mobile_events')

),

web_data_subset as (

    select

        event_id,
        event_type,
        session_id,
        event_timestamp,
        user_id,
        user_access_type,
        item_id,
        item_type,
        item_title,
        country_code as user_country,
        'web' as source_type

    from {{ ref('stg_web_events') }}

),

mobile_data_subset as (

    select 

        event_id,
        event_type,
        session_id,
        event_timestamp,
        user_id,
        user_access_type,
        item_id,
        item_type,
        item_title,
        device_locale_country as user_country,
        'app' as source_type

      from {{ ref('stg_mobile_events') }}

),

unioned as (

    select * from web_data_subset

    union all

    select * from mobile_data_subset

),

final as (

    select 

        *,

        -- temporal features
        year(event_timestamp) as event_year,
        month(event_timestamp) as event_month,
        cast(event_timestamp as date) as event_date,
        isodow(event_timestamp) as event_day_of_week,
         case 
            when isodow(event_timestamp) in (6, 7) then 1
            else 0
        end as event_is_weekend,
        hour(event_timestamp) as event_hour,

        -- session features
        min(event_timestamp) over (partition by user_id, session_id) as session_start,
        max(event_timestamp) over (partition by user_id, session_id) as session_end,

        -- flag events with content interaction
        case
            when count(item_id) over (partition by user_id, session_id) > 0 then 1
            else 0
        end as session_has_interacted

    from unioned
)

select * from final