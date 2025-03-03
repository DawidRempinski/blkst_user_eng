with user_engagement as (

    select * from {{ ref('int_engagement_events') }}
    
),

daily as (

    select

        event_date as date,
    
        -- no. of users who interacted with Blinkist per day
        count(distinct user_id) as daily_active_users,

        -- no. of users who interacted with Blinkist content per day
        count(distinct user_id) filter (where session_has_interacted = 1) as daily_active_learners,

        -- no. of content completions per day
        count(distinct event_id) filter (where source_type = 'web' and event_type = 'item-finished') as content_completions_web,

        -- no. of users from the DACH region who interacted with the Blinkist app per day
        count(distinct user_id) filter (where source_type = 'app' and lower(user_country) in ('de','at','ch')) as daily_active_users_dach

    from user_engagement

    group by 1

)

select * from daily
order by date