WITH route_flights AS (
    SELECT 
        origin,
        dest,
        COUNT(*) AS total_flights,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines,
        AVG(actual_elapsed_time) AS avg_actual_elapsed_time,
        AVG(arr_delay) AS avg_arrival_delay,
        MAX(arr_delay) AS max_arrival_delay,
        MIN(arr_delay) AS min_arrival_delay,
        SUM(cancelled) AS total_cancelled,
        SUM(diverted) AS total_diverted
    FROM {{ ref('prep_flights') }}  -- Fixed: added ref()
    GROUP BY origin, dest
)
SELECT 
    rf.origin,
    rf.dest,
    oa.name AS origin_airport_name,
    oa.city AS origin_city,
    oa.country AS origin_country,
    da.name AS dest_airport_name,
    da.city AS dest_city,
    da.country AS dest_country,
    rf.total_flights,
    rf.unique_airplanes,
    rf.unique_airlines,
    ROUND(rf.avg_actual_elapsed_time, 2) AS avg_actual_elapsed_time_minutes,
    ROUND(rf.avg_arrival_delay, 2) AS avg_arrival_delay_minutes,
    rf.max_arrival_delay,
    rf.min_arrival_delay,
    rf.total_cancelled,
    rf.total_diverted
FROM route_flights rf
LEFT JOIN {{ ref('prep_airports') }} oa
    ON rf.origin = oa.faa
LEFT JOIN {{ ref('prep_airports') }} da
    ON rf.dest = da.faa
ORDER BY rf.origin, rf.dest
