WITH airport_flights AS (
    -- Combine departures and arrivals - only get needed columns
    SELECT 
        origin AS airport_code,
        flight_date,
        tail_number,
        airline,
        cancelled,
        diverted
    FROM {{ ref('prep_flights') }}
    
    UNION ALL
    
    SELECT 
        dest AS airport_code,
        flight_date,
        tail_number,
        airline,
        cancelled,
        diverted
    FROM {{ ref('prep_flights') }}
),

-- Aggregate flights per airport per day first (reduces data size)
daily_flight_aggregates AS (
    SELECT
        airport_code,
        flight_date,
        COUNT(*) AS total_planned_flights,
        SUM(cancelled) AS total_cancelled,
        SUM(diverted) AS total_diverted,
        SUM(CASE WHEN cancelled = 0 AND diverted = 0 THEN 1 ELSE 0 END) AS total_actual_flights,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines,
        COUNT(DISTINCT CASE WHEN origin = airport_code THEN tail_number || '|' || airline END) AS unique_departures,
        COUNT(DISTINCT CASE WHEN dest = airport_code THEN tail_number || '|' || airline END) AS unique_arrivals
    FROM (
        SELECT 
            f.origin AS airport_code,
            f.flight_date,
            f.tail_number,
            f.airline,
            f.cancelled,
            f.diverted,
            f.origin,
            f.dest
        FROM {{ ref('prep_flights') }} f
    ) flight_details
    GROUP BY airport_code, flight_date
)

-- Final select with weather join
SELECT
    dfa.airport_code AS faa,
    pa.name AS airport_name,
    pa.city,
    pa.country,
    dfa.flight_date,
    dfa.unique_departures,
    dfa.unique_arrivals,
    dfa.total_planned_flights,
    dfa.total_cancelled,
    dfa.total_diverted,
    dfa.total_actual_flights,
    dfa.unique_airplanes AS daily_unique_airplanes,
    dfa.unique_airlines AS daily_unique_airlines,
    wd.min_temp_c,
    wd.max_temp_c,
    wd.precipitation_mm,
    wd.max_snow_mm AS daily_snow_fall,
    wd.avg_wind_direction,
    wd.avg_wind_speed_kmh,
    wd.wind_peakgust_kmh
FROM daily_flight_aggregates dfa
INNER JOIN {{ ref('prep_weather_daily') }} wd 
    ON dfa.airport_code = wd.airport_code 
    AND dfa.flight_date = wd.date
LEFT JOIN {{ ref('prep_airports') }} pa 
    ON dfa.airport_code = pa.faa
ORDER BY dfa.airport_code, dfa.flight_date