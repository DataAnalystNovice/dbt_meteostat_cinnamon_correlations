WITH airport_flights AS (
    -- Combine departures and arrivals
    SELECT 
        origin AS airport_code,
        flight_date,
        tail_number,
        airline,
        cancelled,
        diverted,
        1 AS is_departure,
        0 AS is_arrival
    FROM {{ ref('prep_flights') }}
    
    UNION ALL
    
    SELECT 
        dest AS airport_code,
        flight_date,
        tail_number,
        airline,
        cancelled,
        diverted,
        0 AS is_departure,
        1 AS is_arrival
    FROM {{ ref('prep_flights') }}
),

daily_airport_stats AS (
    SELECT
        af.airport_code,
        af.flight_date,
        COUNT(DISTINCT CASE WHEN is_departure = 1 
            THEN af.flight_date::text || '_' || af.tail_number || '_' || af.airline 
        END) AS unique_departures,
        COUNT(DISTINCT CASE WHEN is_arrival = 1 
            THEN af.flight_date::text || '_' || af.tail_number || '_' || af.airline 
        END) AS unique_arrivals,
        COUNT(*) AS total_planned_flights,
        SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_cancelled,
        SUM(CASE WHEN diverted = 1 THEN 1 ELSE 0 END) AS total_diverted,
        SUM(CASE WHEN cancelled = 0 AND diverted = 0 THEN 1 ELSE 0 END) AS total_actual_flights,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines
    FROM airport_flights af
    -- Only include airports that have weather data
    INNER JOIN {{ ref('prep_weather_daily') }} wd 
        ON af.airport_code = wd.airport_code 
        AND af.flight_date = wd.date
    GROUP BY af.airport_code, af.flight_date
)

SELECT
    das.airport_code AS faa,
    pa.name AS airport_name,
    pa.city,
    pa.country,
    das.flight_date,
    das.unique_departures,
    das.unique_arrivals,
    das.total_planned_flights,
    das.total_cancelled,
    das.total_diverted,
    das.total_actual_flights,
    -- Optional metrics
    das.unique_airplanes AS daily_unique_airplanes,
    das.unique_airlines AS daily_unique_airlines,
    -- Weather metrics
    wd.min_temp_c,
    wd.max_temp_c,
    wd.precipitation_mm,
    wd.max_snowfall_mm AS daily_snow_fall,
    wd.avg_wind_direction,
    wd.avg_wind_speed_kmh,
    wd.wind_peakgust_kmh
FROM daily_airport_stats das
LEFT JOIN {{ ref('prep_airports') }} pa ON das.airport_code = pa.faa
LEFT JOIN {{ ref('prep_weather_daily') }} wd 
    ON das.airport_code = wd.airport_code 
    AND das.flight_date = wd.date
ORDER BY das.airport_code, das.flight_date
