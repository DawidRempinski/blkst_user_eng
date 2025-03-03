{%- set day_intervals = [7, 30, 90] -%}

with metrics_daily as (

    select * from {{ ref('fct_engagement_daily') }}

),

add_current_date as ( -- simulate current date for testing purposes

    select

        *,
        max(date) over() as current_date

    from metrics_daily

)

{% for interval in day_intervals %}

, last_{{ interval }}_days as (

    select
    
        'last {{ interval }} days' as aggregation_period,
        sum(daily_active_users) as daily_active_users,
        sum(daily_active_learners) as daily_active_learners,
        sum(content_completions_web) as content_completions_web,
        sum(daily_active_users_dach) as daily_active_users_dach

    from add_current_date

    where date between current_date - interval '{{ interval }} day' and current_date

)

{% endfor %}

select

    *

from (
    {% for interval in day_intervals %}
        select * from last_{{ interval }}_days
        {% if not loop.last %} union all {% endif %}
    {% endfor %}
)

