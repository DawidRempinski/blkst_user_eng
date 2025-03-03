-- 1. Daily Active Users (DAU) and 2. Daily Active Learners (DAL)

WITH combined_events AS (
    SELECT DISTINCT
        CAST(event_timestamp AS DATE) AS event_date,
        user_id, 
        session_id,
        user_access_type,
        country_code AS user_country,
        'web' AS source_type,
        event_name,
        item_id
    FROM read_csv_auto('raw/web_events.csv')

    UNION ALL

    SELECT DISTINCT
        CAST(event_timestamp AS DATE) AS event_date,
        user_id, 
        session_id,
        user_access_type,
        SPLIT_PART(device_locale_code, '_', 2) AS user_country,
        'app' AS source_type,
        event_name,
        item_id
    FROM read_csv_auto('raw/mobile_events.csv')
)

SELECT 
    event_date,

    -- Daily Active Users (DAU)
    COUNT(DISTINCT user_id) AS daily_active_users,

    -- Daily Active Learners (DAL)
    COUNT(DISTINCT CASE WHEN item_id IS NOT NULL THEN user_id END) AS daily_active_learners

FROM combined_events
GROUP BY event_date
ORDER BY event_date ASC;

-- 3. Content Completions on web platform

WITH combined_events AS (
    SELECT DISTINCT
        CAST(event_timestamp AS DATE) AS event_date,
        user_id, 
        session_id,
        user_access_type,
        country_code AS user_country,
        'web' AS source_type,
        event_name,
        item_id
    FROM read_csv_auto('raw/web_events.csv')

    UNION ALL

    SELECT DISTINCT
        CAST(event_timestamp AS DATE) AS event_date,
        user_id, 
        session_id,
        user_access_type,
        SPLIT_PART(device_locale_code, '_', 2) AS user_country,
        'app' AS source_type,
        event_name,
        item_id
    FROM read_csv_auto('raw/mobile_events.csv')
)

SELECT 
    SUM(CASE WHEN event_name = 'item-finished' AND source_type = 'web' THEN 1 END) AS total_content_completions_web
FROM combined_events;

-- 4. Regional Activity - Active App Users in DACH region in last 30 days

WITH combined_events AS (
    SELECT DISTINCT
        CAST(event_timestamp AS DATE) AS event_date,
        user_id, 
        session_id,
        user_access_type,
        country_code AS user_country,
        'web' AS source_type,
        event_name,
        item_id
    FROM read_csv_auto('raw/web_events.csv')

    UNION ALL

    SELECT DISTINCT
        CAST(event_timestamp AS DATE) AS event_date,
        user_id, 
        session_id,
        user_access_type,
        SPLIT_PART(device_locale_code, '_', 2) AS user_country,
        'app' AS source_type,
        event_name,
        item_id
    FROM read_csv_auto('raw/mobile_events.csv')
)

SELECT 
    COUNT(DISTINCT CASE 
        WHEN user_country IN ('DE', 'AT', 'CH') 
        AND source_type = 'app' 
        THEN user_id 
    END) AS active_app_users_dach_last_30_days
FROM combined_events
WHERE event_date BETWEEN CURRENT_DATE - INTERVAL '30' DAY AND CURRENT_DATE;