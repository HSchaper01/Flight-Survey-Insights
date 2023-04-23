
-- Let's take a look at all the information we've been presented
SELECT * FROM pass_satisfaction



-- There seems to be a serial for each customer in the "ID" cloumn
-- Since we won't join with additional tables
-- this primary key won't be useful to us
SELECT ID, Gender, Age FROM pass_satisfaction


-- Let's look at the gender split for the airline
-- starting with men
CREATE VIEW num_men AS
SELECT CAST(SUM (CASE Gender -- Because the source of the data is a float, the ROUND() function will leave trailing zeroes
WHEN 'Female' THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) *100 AS decimal(16,2)) AS percent_men -- mult. by 1.0 to cast as a float and mult. by 100 to get the percentage
FROM pass_satisfaction

-- moving on to women
CREATE VIEW num_women AS
SELECT 
CAST(SUM (CASE Gender
	WHEN 'Male' THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) *100 AS decimal(16,2)) AS percent_women
FROM pass_satisfaction

-- The insights indicate that men fly with the airline
-- slightly more often than women
SELECT percent_men, percent_women FROM num_men, num_women


-- Let's look at the gender breakdown
-- per type of travel class
ALTER VIEW women_class_breakdown AS
SELECT Gender, 
CAST(SUM(CASE 
	WHEN Class = 'Economy'
	THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) * 100 AS decimal (16,2)) AS percent_econ_flights,
CAST(SUM(CASE 
	WHEN Class = 'Economy Plus'
	THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) * 100 AS decimal (16,2)) AS percent_econ_plus_flights,
CAST(SUM(CASE 
	WHEN Class = 'Business'
	THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) * 100 AS decimal (16,2)) AS percent_biz_plus_flights
FROM pass_satisfaction
WHERE Gender = 'Female'
GROUP BY Gender

-- Now let's move on to
-- the men's breakdown
ALTER VIEW men_class_breakdowns AS
SELECT Gender, 
CAST(SUM(CASE 
	WHEN Class = 'Economy'
	THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) * 100 AS decimal (16,2)) AS percent_econ_flights,
CAST(SUM(CASE 
	WHEN Class = 'Economy Plus'
	THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) * 100 AS decimal (16,2)) AS percent_econ_plus_flights,
CAST(SUM(CASE 
	WHEN Class = 'Business'
	THEN 1
	ELSE 0
END) / (1.0 * COUNT(*)) * 100 AS decimal (16,2)) AS percent_biz_plus_flights
FROM pass_satisfaction
WHERE Gender = 'Male'
GROUP BY Gender


-- Our insights indicate that there are
-- no significant differences between genders
-- when looking at class types
SELECT * FROM men_class_breakdowns
UNION
SELECT * FROM women_class_breakdown



-- Let's take a look at avg customer scores 
-- per Gender breakdown
CREATE VIEW ratings_per_gender AS
SELECT 
Gender,
CAST(AVG(Departure_and_Arrival_Time_Convenience)
AS DECIMAL(16,2))
AS Departure_and_Arrival_Time_Convenience,
CAST(AVG(Ease_of_Online_Booking)
AS DECIMAL(16,2))
AS Ease_of_Online_Booking,
CAST(AVG("Check-in_Service")
AS DECIMAL(16,2))
AS "Check-in_Service",
CAST(AVG(Online_Boarding)
AS DECIMAL(16,2))
AS Online_Boarding,
CAST(AVG(Gate_Location)
AS DECIMAL(16,2))
AS Gate_Location,
CAST(AVG("On-board_Service")
AS DECIMAL(16,2))
AS "On-board_Service",
CAST(AVG(Seat_Comfort)
AS DECIMAL(16,2))
AS Seat_Comfort,
CAST(AVG(Leg_Room_Service)
AS DECIMAL(16,2))
AS Leg_Room_Service,
CAST(AVG(Cleanliness)
AS DECIMAL(16,2))
AS Cleanliness,
CAST(AVG(Food_and_Drink)
AS DECIMAL(16,2))
AS Food_and_Drink,
CAST(AVG("In-flight_Service")
AS DECIMAL(16,2))
AS "In-flight_Service",
CAST(AVG("In-flight_Wifi_Service")
AS DECIMAL(16,2))
AS "In-flight_Wifi_Service",
CAST(AVG("In-flight_Entertainment")
AS DECIMAL(16,2))
AS "In-flight_Entertainment",
CAST(AVG(Baggage_Handling)
AS DECIMAL(16,2))
AS Baggage_Handling
FROM pass_satisfaction
GROUP BY 
Gender


-- There's no significant disparity between
-- men and women's ratings,
-- it's interesting to note that
-- the highest rating for both men and women is in-flight service,
SELECT * FROM ratings_per_gender


-- Now let's take alook at ratings
-- per class, it's hypothesized that
-- the higher the class, the higher the ratings
CREATE VIEW ratings_per_class AS
SELECT 
Class,
CAST(AVG(Departure_and_Arrival_Time_Convenience)
AS DECIMAL(16,2))
AS Departure_and_Arrival_Time_Convenience,
CAST(AVG(Ease_of_Online_Booking)
AS DECIMAL(16,2))
AS Ease_of_Online_Booking,
CAST(AVG("Check-in_Service")
AS DECIMAL(16,2))
AS "Check-in_Service",
CAST(AVG(Online_Boarding)
AS DECIMAL(16,2))
AS Online_Boarding,
CAST(AVG(Gate_Location)
AS DECIMAL(16,2))
AS Gate_Location,
CAST(AVG("On-board_Service")
AS DECIMAL(16,2))
AS "On-board_Service",
CAST(AVG(Seat_Comfort)
AS DECIMAL(16,2))
AS Seat_Comfort,
CAST(AVG(Leg_Room_Service)
AS DECIMAL(16,2))
AS Leg_Room_Service,
CAST(AVG(Cleanliness)
AS DECIMAL(16,2))
AS Cleanliness,
CAST(AVG(Food_and_Drink)
AS DECIMAL(16,2))
AS Food_and_Drink,
CAST(AVG("In-flight_Service")
AS DECIMAL(16,2))
AS "In-flight_Service",
CAST(AVG("In-flight_Wifi_Service")
AS DECIMAL(16,2))
AS "In-flight_Wifi_Service",
CAST(AVG("In-flight_Entertainment")
AS DECIMAL(16,2))
AS "In-flight_Entertainment",
CAST(AVG(Baggage_Handling)
AS DECIMAL(16,2))
AS Baggage_Handling
FROM pass_satisfaction
GROUP BY 
Class

-- Our hypothesis has been validated
-- Rating is positively correlated with class
SELECT * FROM ratings_per_class




-- Let's look at wether delays 
-- impact overall satisfaction
ALTER VIEW no_delays AS
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction LIKE 'Satisfied'
	AND Departure_Delay = 0
	AND Arrival_Delay = 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Arrival_Delay = 0
AND Departure_Delay = 0)) AS DECIMAL(16,2)) AS sat_no_delays
FROM pass_satisfaction 
WHERE satisfaction = 'Satisfied'
GROUP BY Satisfaction
UNION
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction NOT LIKE 'Satisfied'        -- NOT LIKE 'Satisfied' leaves the only other option which is 'Neutral or Dissatisfied'
	AND Departure_Delay = 0
	AND Arrival_Delay = 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Arrival_Delay = 0
AND Departure_Delay = 0)) AS DECIMAL(16,2))
FROM pass_satisfaction 
WHERE satisfaction NOT LIKE 'Satisfied'
GROUP BY Satisfaction

-- No delays query ^^^

CREATE VIEW departure_delays AS
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction LIKE 'Satisfied'
	AND Departure_Delay = 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Departure_Delay = 0)) AS DECIMAL(16,2))  AS sat_no_departure_delays
FROM pass_satisfaction 
WHERE satisfaction = 'Satisfied'
GROUP BY Satisfaction
UNION
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction NOT LIKE 'Satisfied'
	AND Departure_Delay = 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Departure_Delay = 0)) AS DECIMAL(16,2))
FROM pass_satisfaction 
WHERE satisfaction NOT LIKE 'Satisfied'
GROUP BY Satisfaction

-- No departure delays query ^^^


ALTER VIEW no_arrival AS
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction LIKE 'Satisfied'
	AND Arrival_Delay = 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Arrival_Delay = 0)) AS DECIMAL(16,2)) AS sat_no_arrival_delays
FROM pass_satisfaction 
WHERE satisfaction LIKE 'Satisfied'
GROUP BY Satisfaction
UNION
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction NOT LIKE 'Satisfied'
	AND Arrival_Delay = 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Arrival_Delay = 0)) AS DECIMAL(16,2))
FROM pass_satisfaction 
WHERE satisfaction NOT LIKE 'Satisfied'
GROUP BY Satisfaction

-- No Arrival delays query ^^^


CREATE VIEW arrival_and_departure AS
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction LIKE 'Satisfied'
	AND Departure_Delay > 0
	AND Arrival_Delay > 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Arrival_Delay > 0
AND Departure_Delay > 0)) AS DECIMAL(16,2)) AS sat_arr_and_dep_delays
FROM pass_satisfaction 
WHERE satisfaction = 'Satisfied'
GROUP BY Satisfaction
UNION
SELECT satisfaction, CAST((1.0 * SUM(CASE
	WHEN 
	satisfaction NOT LIKE 'Satisfied'
	AND Departure_Delay > 0
	AND Arrival_Delay > 0
	THEN 1
	ELSE 0
	END) / (SELECT COUNT(*) FROM pass_satisfaction
WHERE Arrival_Delay > 0
AND Departure_Delay > 0)) AS DECIMAL(16,2))
FROM pass_satisfaction 
WHERE satisfaction NOT LIKE 'Satisfied'
GROUP BY Satisfaction

-- Arrival AND departure delays query ^^^

-- not surprisingly, flights with no delays had the 
-- highest 'Satisfied' percentage
SELECT * FROM no_delays

-- departure delays negatively impacted 
-- satisfaction scores slightly more than 
-- arrival delays
SELECT * FROM departure_delays
SELECT * FROM no_arrival

-- although the previous 3 situations only had a few 
-- percentage points of variance, departure and arrival
-- delays significantly increase dissatisfaction scores 
-- (62% compared to an average of 53% in the previous 3 scenarios)
SELECT * FROM arrival_and_departure


-- Let's look at the average flihgt distance
SELECT CAST(AVG(Flight_Distance) AS DECIMAL (16,2)) AS avg_flight_dist FROM pass_satisfaction 


-- It looks like passengers are usually less satisfied on shorter flights
-- than on longer flights
SELECT CAST(AVG(Flight_Distance) AS DECIMAL (16,2)) AS avg_sat_flight_dist FROM pass_satisfaction 
WHERE Satisfaction LIKE 'Satisfied'

SELECT CAST(AVG(Flight_Distance) AS DECIMAL (16,2)) AS avg_dessat_flight_dist FROM pass_satisfaction 
WHERE Satisfaction NOT LIKE 'Satisfied'


-- Let's take a look at average age per gender,
-- coincidentially, both men and women have an 
-- average age of 39
SELECT CAST(AVG(Age) AS INTEGER), Gender FROM pass_satisfaction
GROUP BY Gender

-- The economy class has the youngest population (37 years old)
-- compared to the business class, which is the oldest class at 41 years old
SELECT Class, CAST(AVG(Age) AS INTEGER) AS avg_age FROM pass_satisfaction
GROUP BY Class

-- Let's look at satisfaction ratings per 
-- customer type (either first-time or repeating clients)
CREATE VIEW sat_per_cust_type AS
SELECT Customer_Type, CAST((SUM(CASE
	WHEN Satisfaction LIKE 'Satisfied'
	AND Customer_Type LIKE 'First-Time'
	THEN 1
	ELSE 0
	END) / (1.0*(SELECT COUNT(*) FROM pass_satisfaction WHERE Customer_Type LIKE 'first_time'))) AS DECIMAL (16,2)) * 100 AS sat_psngrs, 
	CAST((SUM(CASE
	WHEN Satisfaction NOT LIKE 'Satisfied'
	AND Customer_Type LIKE 'First-Time'
	THEN 1
	ELSE 0
	END) / (1.0*(SELECT COUNT(*) FROM pass_satisfaction WHERE Customer_Type LIKE 'first_time'))) AS DECIMAL(16,2)) * 100 AS not_satisfied_psngrs
FROM pass_satisfaction
WHERE Customer_Type LIKE 'First-Time'
GROUP BY Customer_Type
UNION
SELECT Customer_Type, CAST((SUM(CASE
	WHEN Satisfaction LIKE 'Satisfied'
	AND Customer_Type NOT LIKE 'First-Time'
	THEN 1
	ELSE 0
	END) / (1.0*(SELECT COUNT(*) FROM pass_satisfaction WHERE Customer_Type NOT LIKE 'first_time'))) AS DECIMAL (16,2)) * 100 AS sat_psngrs, 
	CAST((SUM(CASE
	WHEN Satisfaction NOT LIKE 'Satisfied'
	AND Customer_Type NOT LIKE 'First-Time'
	THEN 1
	ELSE 0
	END) / (1.0*(SELECT COUNT(*) FROM pass_satisfaction WHERE Customer_Type NOT LIKE 'first_time'))) AS DECIMAL(16,2)) * 100 AS not_satisfied_psngrs
FROM pass_satisfaction
WHERE Customer_Type NOT LIKE 'First-Time'
GROUP BY Customer_Type

-- the data reveals that first-time passengers
-- are almost half as satisfied as repeat passengers
SELECT * FROM sat_per_cust_type


-- Let's look at whether the airline is more favorable with
-- younger generations or older folks
-- starting with younger people under 30
CREATE VIEW young_satisfaction AS
SELECT CAST(SUM(CASE
	WHEN satisfaction LIKE 'Satisfied'
	AND age < 30
	THEN 1
	ELSE 0
	END) /  (1.0 * (SELECT COUNT(*) FROM pass_satisfaction WHERE age < 30)) * 100 AS DECIMAL(16,2))
	AS young_and_satisfied,
	CAST(SUM(CASE
	WHEN satisfaction NOT LIKE 'Satisfied'
	AND age < 30
	THEN 1
	ELSE 0
	END) /  (1.0 * (SELECT COUNT(*) FROM pass_satisfaction WHERE age < 30)) * 100 AS DECIMAL(16,2))
	AS young_and_dissatisfied
	FROM pass_satisfaction

-- looking at people over 30
CREATE VIEW older_satisfaction AS
SELECT CAST(SUM(CASE
	WHEN satisfaction LIKE 'Satisfied'
	AND age > 30
	THEN 1
	ELSE 0
	END) /  (1.0 * (SELECT COUNT(*) FROM pass_satisfaction WHERE age > 30)) * 100 AS DECIMAL(16,2))
	AS mature_and_satisfied,
	CAST(SUM(CASE
	WHEN satisfaction NOT LIKE 'Satisfied'
	AND age > 30
	THEN 1
	ELSE 0
	END) /  (1.0 * (SELECT COUNT(*) FROM pass_satisfaction WHERE age > 30)) * 100 AS DECIMAL(16,2))
	AS older_and_dissatisfied
	FROM pass_satisfaction

-- The data shows that the younger segments
-- of the airline's clientele are significantly
-- more dissatisifed than the older generations
SELECT * FROM young_satisfaction
SELECT * FROM older_satisfaction

-- Let's look at the age distribution of the airline
-- The population seems to be concentrated around the 30-55 range
SELECT AGE, COUNT(Age) FROM pass_satisfaction
GROUP BY Age
ORDER BY Age


-- Here's all the insights we were
-- able to produce: 


-- Gender breakdown
SELECT percent_men, percent_women FROM num_men, num_women

-- Gender breakdown per class
SELECT * FROM men_class_breakdowns
UNION
SELECT * FROM women_class_breakdown


-- Ratings per class
SELECT * FROM ratings_per_class


-- Ratings per gender
SELECT * FROM ratings_per_gender


-- Ratings when there were no delays
SELECT * FROM no_delays

-- Ratings when there were no departure delays
SELECT * FROM departure_delays

-- Ratings when there were no arrival delays 
SELECT * FROM no_arrival

-- Ratings when there were both arrival and departure delays
SELECT * FROM arrival_and_departure


-- Average flight distance
SELECT CAST(AVG(Flight_Distance) AS DECIMAL (16,2)) AS avg_flight_dist FROM pass_satisfaction 


-- Average flight distance when flyers are satisifed
SELECT CAST(AVG(Flight_Distance) AS DECIMAL (16,2)) AS avg_sat_flight_dist FROM pass_satisfaction 
WHERE Satisfaction LIKE 'Satisfied'


-- Average flight distance when flyers are not satisfied
SELECT CAST(AVG(Flight_Distance) AS DECIMAL (16,2)) AS avg_dessat_flight_dist FROM pass_satisfaction 
WHERE Satisfaction NOT LIKE 'Satisfied'


-- Satisfaction per flyer type (first time vs. returning) 
SELECT * FROM sat_per_cust_type


-- Age distribution across the airline
SELECT AGE, COUNT(Age) FROM pass_satisfaction
GROUP BY Age
ORDER BY Age


-- Satisfaction per age group (young < 30, mature > 30) 
SELECT * FROM young_satisfaction
SELECT * FROM older_satisfaction



-- THANK YOU FOR TAKING A LOOK AT MY INSIGHTS! 