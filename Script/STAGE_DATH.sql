CREATE DATABASE STAGE_DATH
GO

USE STAGE_DATH
GO

DROP TABLE IF EXISTS STG_Airline;
GO

CREATE TABLE STG_Airline (
    Iata_Code CHAR(2),
    Airline NVARCHAR(255)
 
);

DROP TABLE IF EXISTS STG_Airport;
GO
CREATE TABLE STG_Airport (
    Iata_Code CHAR(3),
    Airport_Name VARCHAR(255),
    City_Name VARCHAR(255),
    State_Code VARCHAR(50),
    Country_Name VARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
 
);

DROP TABLE IF EXISTS STG_Flight;
GO
CREATE TABLE STG_Flight (
	Year_Value INT,
    Month_Value INT,
    Day_Value INT,
    Day_Of_Week INT,
    Iata_Airline CHAR(2),
    Flight_Number INT,
    Time_Id INT,
    Tail_Number VARCHAR(20),
    Origin_Airport CHAR(3),
    Destination_Airport CHAR(3),
	Distance Int,
    Scheduled_Departure INT,
    Departure_Time INT,
    Departure_Delay INT,
    Taxi_Out INT,
    Wheels_Off INT,
    Scheduled_Time INT,
    Elapsed_Time INT,
    Air_Time INT,
    Wheels_On INT,
    Taxi_In INT,
    Scheduled_Arrival INT,
    Arrival_Time INT,
    Arrival_Delay INT,
    Diverted BIT,
    Cancelled BIT,
    Air_System_Delay INT,
    Security_Delay INT,
    Airline_Delay INT,
    Late_Aircraft_Delay INT,
    Weather_Delay INT,
    Cancellation_Reason CHAR(1)

   
);

SELECT * FROM STG_Airline

SELECT * FROM STG_Airport
SELECT * FROM STG_Flight