USE nyc_tlc;

-- Q1. How does HVFHV trip demand vary by month, day of week, and hour of day across Q1 2026?
CREATE OR REPLACE VIEW q1_trip_demand AS
WITH hourly_demand AS 
		(SELECT trip_month, WEEKDAY(pickup_datetime) + 1 AS day_number,
			DAYNAME(pickup_datetime) AS day_of_week, HOUR(pickup_datetime) AS trip_hour,
			COUNT(*) AS trip_count
		FROM q1_hvfhv_trips
		GROUP BY trip_month, WEEKDAY(pickup_datetime) + 1, DAYNAME(pickup_datetime),
        HOUR(pickup_datetime)),

demand_metrics AS
		(SELECT trip_month, day_number, day_of_week, trip_hour, trip_count,
			SUM(trip_count) OVER (PARTITION BY trip_month) AS monthly_total,
			SUM(trip_count) OVER (PARTITION BY trip_month, day_number) AS day_total,
			RANK() OVER (PARTITION BY trip_month ORDER BY trip_count DESC) AS monthly_hour_rank,
			RANK() OVER (PARTITION BY trip_month, day_number ORDER BY trip_count DESC) AS hourly_rank_within_day
		FROM hourly_demand)

SELECT	trip_month, day_number, day_of_week, trip_hour, trip_count,
		ROUND(100.0 * trip_count / monthly_total,2) AS pct_of_monthly_demand, day_total,
        ROUND(100.0 * day_total / monthly_total,2) AS pct_of_monthly_day_demand,
        monthly_hour_rank, hourly_rank_within_day
FROM demand_metrics;

SELECT * FROM q1_trip_demand;

-- Q2. How does trip demand and market share differ between HVFHV providers (HV0003 vs HV0005)?
CREATE OR REPLACE VIEW q2_provider_demand_market_share AS
WITH provider_demand AS (
		SELECT trip_month, hvfhs_license_num AS provider, COUNT(*) AS trip_count
		FROM q1_hvfhv_trips
		WHERE hvfhs_license_num IN ('HV0003', 'HV0005')
		GROUP BY trip_month,hvfhs_license_num),
        
provider_metrics AS (
	SELECT trip_month, provider,trip_count,
		SUM(trip_count) OVER (PARTITION BY trip_month) AS monthly_total_trips,
		SUM(trip_count) OVER (PARTITION BY provider) AS q1_provider_total_trips,
		SUM(trip_count) OVER () AS q1_total_trips,
        RANK() OVER (PARTITION BY trip_month 
        ORDER BY trip_count DESC) AS monthly_demand_rank
	FROM provider_demand)

SELECT trip_month,provider,trip_count,monthly_total_trips,
		ROUND(100.0 * trip_count / monthly_total_trips,2) AS monthly_market_share_pct,
		q1_provider_total_trips,q1_total_trips,
		ROUND(100.0 * q1_provider_total_trips / q1_total_trips,2) AS q1_market_share_pct,
		monthly_demand_rank
FROM provider_metrics;

SELECT * FROM q2_provider_demand_market_share
ORDER BY FIELD(trip_month, 'January', 'February', 'March'),provider;

-- Q3. How do the two providers compare in average fare, driver pay, tips, and trip distance?
CREATE OR REPLACE VIEW q3_provider_economics AS
WITH provider_monthly AS 
		(SELECT trip_month, hvfhs_license_num AS provider,
		COUNT(*) AS trip_count, SUM(base_passenger_fare) AS total_fare,
        SUM(driver_pay) AS total_driver_pay, SUM(tips) AS total_tips,
		SUM(trip_miles) AS total_trip_distance
		FROM q1_hvfhv_trips
		WHERE hvfhs_license_num IN ('HV0003', 'HV0005')
		GROUP BY trip_month, hvfhs_license_num),

provider_metrics AS (
	SELECT trip_month, provider, trip_count, total_fare,
        total_driver_pay, total_tips, total_trip_distance,
		total_fare / trip_count AS avg_fare,
        total_driver_pay / trip_count AS avg_driver_pay,
        total_tips / trip_count AS avg_tips,
        total_trip_distance / trip_count AS avg_trip_distance,
		SUM(total_fare) OVER (PARTITION BY provider) AS q1_total_fare,
		SUM(total_driver_pay) OVER (PARTITION BY provider) AS q1_total_driver_pay,
		SUM(total_tips) OVER (PARTITION BY provider) AS q1_total_tips,
		SUM(total_trip_distance) OVER (PARTITION BY provider) AS q1_total_trip_distance,
		SUM(trip_count) OVER (PARTITION BY provider) AS q1_trip_count
   FROM provider_monthly)

SELECT trip_month, provider, trip_count,
	ROUND(avg_fare, 2) AS avg_fare,
    ROUND(avg_driver_pay, 2) AS avg_driver_pay,
    ROUND(avg_tips, 2) AS avg_tips,
    ROUND(avg_trip_distance, 2) AS avg_trip_distance,
	ROUND(q1_total_fare / q1_trip_count, 2) AS q1_avg_fare,
    ROUND(q1_total_driver_pay / q1_trip_count, 2) AS q1_avg_driver_pay,
    ROUND(q1_total_tips / q1_trip_count, 2) AS q1_avg_tips,
    ROUND(q1_total_trip_distance / q1_trip_count, 2) AS q1_avg_trip_distance
FROM provider_metrics;

SELECT * FROM q3_provider_economics
ORDER BY FIELD(trip_month, 'January', 'February', 'March'),provider;
    
    
-- Q4. Which pickup and drop-off locations generate the highest trip volumes, and which routes are most frequently travelled?
CREATE OR REPLACE VIEW q4_location_route_demand AS
WITH pickup_demand AS 
	    (SELECT PULocationID AS pickup_location, COUNT(*) AS trip_count
		FROM q1_hvfhv_trips
		GROUP BY PULocationID),
 
 pickup_ranked AS 
		(SELECT pickup_location, trip_count,
	     ROUND(100.0 * trip_count /SUM(trip_count) OVER (),2) AS demand_share_pct,
		 RANK() OVER (ORDER BY trip_count DESC) AS demand_rank
		 FROM pickup_demand),

dropoff_demand AS
			(SELECT DOLocationID AS dropoff_location, COUNT(*) AS trip_count
			 FROM q1_hvfhv_trips
			 GROUP BY DOLocationID),

dropoff_ranked AS
		(SELECT dropoff_location, trip_count,
			 ROUND(100.0 * trip_count /SUM(trip_count) OVER (),2) AS demand_share_pct,
			 RANK() OVER (ORDER BY trip_count DESC) AS demand_rank
		 FROM dropoff_demand),

route_demand AS 
	(SELECT PULocationID AS pickup_location,
        DOLocationID AS dropoff_location, COUNT(*) AS trip_count
	FROM q1_hvfhv_trips
	GROUP BY PULocationID, DOLocationID),

route_ranked AS 
		(SELECT pickup_location, dropoff_location, trip_count,
			ROUND(100.0 * trip_count /SUM(trip_count) OVER (),2) AS demand_share_pct,
			RANK() OVER (ORDER BY trip_count DESC) AS demand_rank
		FROM route_demand)

SELECT 'Pickup Location' AS analysis_type,
    CAST(pickup_location AS CHAR) AS pickup_location,
    NULL AS dropoff_location,
    trip_count, demand_share_pct,demand_rank
FROM pickup_ranked
UNION ALL
SELECT 'Drop-off Location' AS analysis_type,
		NULL AS pickup_location,
		CAST(dropoff_location AS CHAR) AS dropoff_location,
		trip_count, demand_share_pct,demand_rank
FROM dropoff_ranked
UNION ALL
SELECT 'Route' AS analysis_type,
		CAST(pickup_location AS CHAR) AS pickup_location,
		CAST(dropoff_location AS CHAR) AS dropoff_location,
		trip_count, demand_share_pct, demand_rank
FROM route_ranked;

SELECT * FROM q4_location_route_demand
ORDER BY analysis_type, demand_rank;

-- Q5. How do trip distance and trip duration relate to passenger fares?
CREATE OR REPLACE VIEW q5_distance_duration_fare AS
WITH distance_analysis AS (
	SELECT CASE
            WHEN trip_miles = 0 THEN '0 miles'
            WHEN trip_miles > 0 AND trip_miles <= 2 THEN '0–2 miles'
            WHEN trip_miles > 2 AND trip_miles <= 5 THEN '2–5 miles'
            WHEN trip_miles > 5 AND trip_miles <= 10 THEN '5–10 miles'
            WHEN trip_miles > 10 AND trip_miles <= 20 THEN '10–20 miles'
            ELSE '20+ miles' END AS distance_band,
		COUNT(*) AS trip_count, AVG(trip_miles) AS avg_distance,
        AVG(base_passenger_fare) AS avg_fare, AVG(driver_pay) AS avg_driver_pay
	FROM q1_hvfhv_trips
	WHERE trip_miles >= 0 AND base_passenger_fare IS NOT NULL
	GROUP BY CASE
            WHEN trip_miles = 0 THEN '0 miles'
            WHEN trip_miles > 0 AND trip_miles <= 2 THEN '0–2 miles'
            WHEN trip_miles > 2 AND trip_miles <= 5 THEN '2–5 miles'
            WHEN trip_miles > 5 AND trip_miles <= 10 THEN '5–10 miles'
            WHEN trip_miles > 10 AND trip_miles <= 20 THEN '10–20 miles'
            ELSE '20+ miles' END),

distance_metrics AS 
					(SELECT 'Distance' AS analysis_dimension, distance_band AS analysis_band,
						trip_count,	avg_distance, avg_fare, avg_driver_pay,
						ROUND(100.0 * trip_count /SUM(trip_count) OVER (),2) AS trip_share_pct,
						RANK() OVER (ORDER BY avg_fare DESC) AS fare_rank
					FROM distance_analysis),

duration_analysis AS 
				(SELECT CASE
						WHEN trip_time = 0 THEN '0 minutes'
						WHEN trip_time > 0 	AND trip_time <= 600 THEN '0–10 minutes'
						WHEN trip_time > 600 AND trip_time <= 1200 THEN '10–20 minutes'
						WHEN trip_time > 1200 AND trip_time <= 1800 THEN '20–30 minutes'
						WHEN trip_time > 1800 AND trip_time <= 2700 THEN '30–45 minutes'
						WHEN trip_time > 2700 AND trip_time <= 3600 THEN '45–60 minutes'
						ELSE '60+ minutes' END AS duration_band,
					COUNT(*) AS trip_count, AVG(trip_time) / 60 AS avg_duration_minutes,
					AVG(base_passenger_fare) AS avg_fare, AVG(driver_pay) AS avg_driver_pay
			FROM q1_hvfhv_trips 
            WHERE trip_time >= 0 AND base_passenger_fare IS NOT NULL
			GROUP BY CASE
						WHEN trip_time = 0 THEN '0 minutes'
						WHEN trip_time > 0 AND trip_time <= 600 THEN '0–10 minutes'
						WHEN trip_time > 600 AND trip_time <= 1200 THEN '10–20 minutes'
						WHEN trip_time > 1200 AND trip_time <= 1800 THEN '20–30 minutes'
						WHEN trip_time > 1800 AND trip_time <= 2700 THEN '30–45 minutes'
						WHEN trip_time > 2700 AND trip_time <= 3600 THEN '45–60 minutes'
						ELSE '60+ minutes'END),

duration_metrics AS 
				(SELECT 'Duration' AS analysis_dimension, duration_band AS analysis_band,
					trip_count, avg_duration_minutes AS avg_distance, avg_fare, avg_driver_pay,
					ROUND(100.0 * trip_count /SUM(trip_count) OVER (),2) AS trip_share_pct,
					RANK() OVER (ORDER BY avg_fare DESC) AS fare_rank
				FROM duration_analysis)


SELECT analysis_dimension, analysis_band, trip_count,
		ROUND(avg_distance, 2) AS avg_distance_or_duration,
		ROUND(avg_fare, 2) AS avg_fare,
		ROUND(avg_driver_pay, 2) AS avg_driver_pay,trip_share_pct,fare_rank
FROM distance_metrics
UNION ALL
SELECT analysis_dimension, analysis_band, trip_count,
	ROUND(avg_distance, 2) AS avg_distance_or_duration,
    ROUND(avg_fare, 2) AS avg_fare,
    ROUND(avg_driver_pay, 2) AS avg_driver_pay,trip_share_pct,fare_rank
FROM duration_metrics;


SELECT * FROM q5_distance_duration_fare
ORDER BY analysis_dimension, fare_rank;
    
-- Q6. How significant are airport trips, and how do airport trips differ from non-airport trips in volume, distance, duration, and fare?
CREATE OR REPLACE VIEW q6_airport_trip_analysis AS
WITH airport_analysis AS 
		(SELECT trip_month, 
					CASE WHEN airport_fee > 0 THEN 'Airport'
					ELSE 'Non-Airport' END AS trip_type,
			COUNT(*) AS trip_count, SUM(trip_miles) AS total_distance,
			SUM(trip_time) AS total_duration, SUM(base_passenger_fare) AS total_fare
		FROM q1_hvfhv_trips
		GROUP BY trip_month,
        CASE WHEN airport_fee > 0 THEN 'Airport' ELSE 'Non-Airport' END),

airport_metrics AS 
			(SELECT trip_month, trip_type, trip_count,
				total_distance / trip_count AS avg_distance,
				(total_duration / trip_count) / 60 AS avg_duration_minutes,
				total_fare / trip_count AS avg_fare,
				SUM(trip_count) OVER (PARTITION BY trip_month) AS monthly_total_trips,
				SUM(trip_count) OVER (PARTITION BY trip_type) AS q1_trip_count,
				SUM(total_distance) OVER (PARTITION BY trip_type) AS q1_total_distance,
				SUM(total_duration) OVER (PARTITION BY trip_type) AS q1_total_duration,
				SUM(total_fare) OVER (PARTITION BY trip_type) AS q1_total_fare
			FROM airport_analysis)

SELECT trip_month, trip_type, trip_count,
		ROUND( 100.0 * trip_count / monthly_total_trips,2) AS monthly_trip_share_pct,
		ROUND(avg_distance, 2) AS avg_distance_miles,
		ROUND(avg_duration_minutes, 2) AS avg_duration_minutes,
		ROUND(avg_fare, 2) AS avg_fare,q1_trip_count,
		ROUND(100.0 * q1_trip_count /SUM(q1_trip_count) OVER (),2) AS q1_trip_share_pct,
		ROUND(q1_total_distance / q1_trip_count,2) AS q1_avg_distance_miles,
		ROUND((q1_total_duration / q1_trip_count) / 60,2) AS q1_avg_duration_minutes,
		ROUND(q1_total_fare / q1_trip_count,2) AS q1_avg_fare
FROM airport_metrics;

SELECT * FROM q6_airport_trip_analysis
ORDER BY FIELD(trip_month, 'January', 'February', 'March'), trip_type;

-- Q7. What is the scale of shared-ride demand, and how often do shared requests result in successful matches?


CREATE OR REPLACE VIEW q7_shared_ride_analysis AS
WITH shared_demand AS 
		(SELECT trip_month,
				SUM( CASE WHEN shared_request_flag = 'Y' THEN 1 ELSE 0 END ) AS shared_requests,
				SUM( CASE WHEN shared_request_flag = 'Y' AND shared_match_flag = 'Y' THEN 1 ELSE 0 END)
				AS successful_matches,	COUNT(*) AS total_trips
		FROM q1_hvfhv_trips
		GROUP BY trip_month),

shared_metrics AS 
		(SELECT trip_month, shared_requests, successful_matches, total_trips,
			SUM(shared_requests) OVER () AS q1_shared_requests,
			SUM(successful_matches) OVER () AS q1_successful_matches,
			SUM(total_trips) OVER () AS q1_total_trips
			FROM shared_demand)

SELECT trip_month,total_trips,shared_requests,
		ROUND(100.0 * shared_requests / total_trips,2) AS shared_request_rate_pct,successful_matches,
		ROUND(100.0 * successful_matches / shared_requests,2) AS shared_match_rate_pct,q1_shared_requests,
		ROUND(100.0 * q1_shared_requests / q1_total_trips,2) AS q1_shared_request_rate_pct,q1_successful_matches,
        ROUND(100.0 * q1_successful_matches / q1_shared_requests,2) AS q1_shared_match_rate_pct
FROM shared_metrics;

SELECT * FROM q7_shared_ride_analysis
ORDER BY FIELD(trip_month, 'January', 'February', 'March');

-- Q8. Are there notable changes or anomalies in demand or trip economics across the three months that require further investigation?
CREATE OR REPLACE VIEW q8_monthly_changes_anomalies AS
WITH daily_demand AS 
		(SELECT trip_month, trip_date, COUNT(*) AS daily_trip_count
		FROM q1_hvfhv_trips
		GROUP BY trip_month, trip_date),

monthly_demand AS 
		(SELECT trip_month, COUNT(*) AS days_recorded,
			SUM(daily_trip_count) AS total_trips,
			AVG(daily_trip_count) AS avg_daily_trips
		FROM daily_demand
		GROUP BY trip_month),

monthly_economics AS 
		(SELECT trip_month,
				AVG(base_passenger_fare) AS avg_fare,
				AVG(driver_pay) AS avg_driver_pay,
				AVG(tips) AS avg_tips,
				AVG(trip_miles) AS avg_trip_distance,
				AVG(trip_time) / 60 AS avg_trip_duration_minutes,
				AVG(CASE WHEN airport_fee > 0 THEN 1.0 ELSE 0.0 END) * 100 AS airport_trip_share_pct,
				AVG(CASE WHEN shared_request_flag = 'Y' THEN 1.0 ELSE 0.0 END ) * 100 AS shared_request_rate_pct
		FROM q1_hvfhv_trips
		GROUP BY trip_month),

monthly_metrics AS 
		(SELECT d.trip_month, d.days_recorded, d.total_trips, d.avg_daily_trips,
				e.avg_fare, e.avg_driver_pay, e.avg_tips, e.avg_trip_distance,
				e.avg_trip_duration_minutes, e.airport_trip_share_pct, e.shared_request_rate_pct
		FROM monthly_demand d
		JOIN monthly_economics e
        ON d.trip_month = e.trip_month),

month_comparison AS
	(SELECT *,
        LAG(avg_daily_trips) OVER ( ORDER BY FIELD(trip_month, 'January', 'February', 'March')) 
		AS previous_avg_daily_trips,
		LAG(avg_fare) OVER (ORDER BY FIELD(trip_month, 'January', 'February', 'March'))
        AS previous_avg_fare,
		LAG(avg_driver_pay) OVER ( ORDER BY FIELD(trip_month, 'January', 'February', 'March'))
        AS previous_avg_driver_pay,
		LAG(avg_tips) OVER (ORDER BY FIELD(trip_month, 'January', 'February', 'March')) 
        AS previous_avg_tips,
		LAG(avg_trip_distance) OVER (ORDER BY FIELD(trip_month, 'January', 'February', 'March')) 
        AS previous_avg_trip_distance,
		LAG(avg_trip_duration_minutes) OVER (ORDER BY FIELD(trip_month, 'January', 'February', 'March')) 
        AS previous_avg_trip_duration,
		LAG(airport_trip_share_pct) OVER ( ORDER BY FIELD(trip_month, 'January', 'February', 'March')) 
        AS previous_airport_share,
		LAG(shared_request_rate_pct) OVER (ORDER BY FIELD(trip_month, 'January', 'February', 'March'))
        AS previous_shared_request_rate
	FROM monthly_metrics)

SELECT trip_month, days_recorded, total_trips,
		ROUND(avg_daily_trips, 0) AS avg_daily_trips,
		ROUND(avg_fare, 2) AS avg_fare,
		ROUND(avg_driver_pay, 2) AS avg_driver_pay,
		ROUND(avg_tips, 2) AS avg_tips,
		ROUND(avg_trip_distance, 2) AS avg_trip_distance,
		ROUND(avg_trip_duration_minutes, 2) AS avg_trip_duration_minutes,
		ROUND(airport_trip_share_pct, 2) AS airport_trip_share_pct,
		ROUND(shared_request_rate_pct, 2) AS shared_request_rate_pct,
		ROUND(100.0 * ( avg_daily_trips - previous_avg_daily_trips) / NULLIF(previous_avg_daily_trips, 0),2)
		AS daily_demand_mom_change_pct,
		ROUND(100.0 * (avg_fare - previous_avg_fare) / NULLIF(previous_avg_fare, 0),2)
		AS fare_mom_change_pct,
		ROUND(100.0 * (avg_driver_pay - previous_avg_driver_pay) / NULLIF(previous_avg_driver_pay, 0),2)
		AS driver_pay_mom_change_pct,
		ROUND(100.0 * (avg_tips - previous_avg_tips) / NULLIF(previous_avg_tips, 0),2) 
        AS tips_mom_change_pct,
		ROUND(100.0 * (avg_trip_distance - previous_avg_trip_distance) / NULLIF(previous_avg_trip_distance, 0),2)
        AS distance_mom_change_pct,
		ROUND(100.0 * (avg_trip_duration_minutes - previous_avg_trip_duration) / NULLIF(previous_avg_trip_duration, 0),2) 
        AS duration_mom_change_pct,
		ROUND(airport_trip_share_pct - previous_airport_share,2) AS airport_share_change_pp,
		ROUND(shared_request_rate_pct - previous_shared_request_rate,2) AS shared_request_rate_change_pp

FROM month_comparison;


SELECT * FROM q8_monthly_changes_anomalies
ORDER BY FIELD(trip_month, 'January', 'February', 'March');