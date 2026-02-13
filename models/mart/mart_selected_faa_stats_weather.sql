CREATE TABLE mart_weather_weekly AS

WITH weekly_base AS (
    SELECT
        airport_code,
        DATE_TRUNC('week', date)::DATE AS week_start_date,
        (DATE_TRUNC('week', date) + INTERVAL '6 days')::DATE AS week_end_date,
        min_temp_c,
        max_temp_c,
        precipitation_mm,
        max_snow_mm,
        avg_wind_direction,
        avg_wind_speed_kmh,
        wind_peakgust_kmh
    FROM prep_weather_daily
),

weekly_aggregates AS (
    SELECT
        airport_code,
        week_start_date,
        week_end_date,
        EXTRACT(WEEK FROM week_start_date) AS week_number,
        EXTRACT(YEAR FROM week_start_date) AS year,
        AVG(min_temp_c) AS avg_min_temp_c,
        AVG(max_temp_c) AS avg_max_temp_c,
        MIN(min_temp_c) AS weekly_min_temp_c,
        MAX(max_temp_c) AS weekly_max_temp_c,
        STDDEV(min_temp_c) AS temp_variability,
        SUM(precipitation_mm) AS total_precipitation_mm,
        SUM(max_snow_mm) AS total_snow_mm,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_wind_direction) AS median_wind_direction,
        AVG(avg_wind_direction) AS avg_wind_direction,
        AVG(avg_wind_speed_kmh) AS avg_wind_speed_kmh,
        STDDEV(avg_wind_speed_kmh) AS wind_speed_variability,
        MAX(wind_peakgust_kmh) AS max_wind_peakgust_kmh,
        COUNT(*) AS days_with_data
    FROM weekly_base
    GROUP BY airport_code, week_start_date, week_end_date
),

wind_mode AS (
    SELECT DISTINCT ON (airport_code, week_start_date)
        airport_code,
        week_start_date,
        avg_wind_direction AS mode_wind_direction
    FROM (
        SELECT
            airport_code,
            DATE_TRUNC('week', date)::DATE AS week_start_date,
            avg_wind_direction,
            COUNT(*) AS frequency
        FROM prep_weather_daily
        GROUP BY airport_code, DATE_TRUNC('week', date), avg_wind_direction
    ) freq
    ORDER BY airport_code, week_start_date, frequency DESC
)

SELECT
    wa.airport_code,
    pa.name AS airport_name,
    pa.city,
    pa.country,
    wa.week_start_date,
    wa.week_end_date,
    wa.week_number,
    wa.year,
    ROUND(wa.avg_min_temp_c, 2) AS avg_min_temp_c,
    ROUND(wa.avg_max_temp_c, 2) AS avg_max_temp_c,
    ROUND(wa.weekly_min_temp_c, 2) AS weekly_min_temp_c,
    ROUND(wa.weekly_max_temp_c, 2) AS weekly_max_temp_c,
    ROUND(wa.temp_variability, 2) AS temp_stddev_c,
    ROUND(wa.total_precipitation_mm, 2) AS total_precipitation_mm,
    ROUND(wa.total_snow_mm, 2) AS total_snowfall_mm,
    ROUND(wm.mode_wind_direction, 0) AS most_common_wind_direction_degrees,
    ROUND(wa.median_wind_direction, 0) AS median_wind_direction_degrees,
    ROUND(wa.avg_wind_direction, 0) AS avg_wind_direction_degrees,
    ROUND(wa.avg_wind_speed_kmh, 2) AS avg_wind_speed_kmh,
    ROUND(wa.wind_speed_variability, 2) AS wind_speed_stddev_kmh,
    ROUND(wa.max_wind_peakgust_kmh, 2) AS max_wind_gust_kmh,
    wa.days_with_data
FROM weekly_aggregates wa
LEFT JOIN prep_airports pa 
    ON wa.airport_code = pa.faa
LEFT JOIN wind_mode wm 
    ON wa.airport_code = wm.airport_code 
    AND wa.week_start_date = wm.week_start_date
ORDER BY wa.airport_code, wa.week_start_date;