-- QUATER 1 - 2026 NYC HVFHV SQL Analysis Questions

-- Q1. How does HVFHV trip demand vary by month, day of week, and hour of day across Q1 2026?
SELECT * FROM q1_trip_demand;

-- Q2. How does trip demand and market share differ between HVFHV providers (HV0003 vs HV0005)?
SELECT * FROM q2_provider_demand_market_share
ORDER BY FIELD(trip_month, 'January', 'February', 'March'), provider;

-- Q3. How do the two providers compare in average fare, driver pay, tips, and trip distance?
SELECT * FROM q3_provider_economics
ORDER BY FIELD(trip_month, 'January', 'February', 'March'),provider;

-- Q4. Which pickup and drop-off locations generate the highest trip volumes, and which routes are most frequently travelled?
SELECT * FROM q4_location_route_demand
ORDER BY analysis_type, demand_rank;

-- Q5. How do trip distance and trip duration relate to passenger fares?
SELECT * FROM q5_distance_duration_fare
ORDER BY analysis_dimension, fare_rank;

-- Q6. How significant are airport trips, and how do airport trips differ from non-airport trips in volume, distance, duration, and fare?
SELECT * FROM q5_distance_duration_fare
ORDER BY analysis_dimension, fare_rank;

-- Q7. What is the scale of shared-ride demand, and how often do shared requests result in successful matches?
SELECT * FROM q7_shared_ride_analysis
ORDER BY FIELD(trip_month, 'January', 'February', 'March');

-- Q8. Are there notable changes or anomalies in demand or trip economics across the three months that require further investigation?
SELECT * FROM q8_monthly_changes_anomalies
ORDER BY FIELD(trip_month, 'January', 'February', 'March');