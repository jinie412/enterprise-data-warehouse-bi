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
    Tail_Number VARCHAR(20),
    Origin_Airport VARCHAR(5), -- từ 3 sang 5
    Destination_Airport VARCHAR(5), -- từ 3 sang 5
	Distance Int,
    Scheduled_Departure INT, -- time
    Departure_Time INT, -- time
    Departure_Delay INT, 
    Taxi_Out INT,
    Wheels_Off INT, -- time
    Scheduled_Time INT,
    Elapsed_Time INT,
    Air_Time INT,
    Wheels_On INT, -- time
    Taxi_In INT,
    Scheduled_Arrival INT, -- time
    Arrival_Time INT, -- time
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

DROP TABLE IF EXISTS STG_AirportCodeMapping;
GO
CREATE TABLE STG_AirportCodeMapping (
    DOT_Code VARCHAR(5),
    IATA_CODE VARCHAR(3)
);

DROP TABLE IF EXISTS [STG_Flight_DOT];
GO
CREATE TABLE [STG_Flight_DOT] (
    [Air_System_Delay_Fix] int,
    [Air_Time_Fix] int,
    [Airline_Delay_Fix] int,
    [Airline_Fix] varchar(2),
    [Arrival_Delay_Fix] int,
    [Arrival_Time_Fix] INT,
    [Cancellation_Reason_Fix] varchar(1),
    [Cancelled_Fix] bit,
    [DAY_Fix] int,
    [DAY_OF_WEEK_Fix] int,
    [Departure_Delay_Fix] int,
    [Departure_Time_Fix] INT,
    [Destination_Airport_Fix] varchar(5),
    [DISTANCE_Fix] int,
    [DIVERTED_Fix] bit,
    [Elapsed_Time_Fix] int,
    [FLIGHT_NUMBER_Fix] int,
    [Late_Aircraft_Delay_Fix] int,
    [MONTH_Fix] int,
    [Origin_Airport_Fix] varchar(5),
    [Scheduled_Arrival_Fix] INT,
    [Scheduled_Departure_Fix] INT,
    [Scheduled_Time_Fix] int,
    [Security_Delay_Fix] int,
    [Tail_Number_Fix] varchar(20),
    [Taxi_In_Fix] int,
    [Taxi_Out_Fix] int,
    [Weather_Delay_Fix] int,
    [Wheels_Off_Fix] INT,
    [Wheels_On_Fix] INT,
    [YEAR_Fix] int
)

SELECT * FROM STG_Airline

SELECT * FROM STG_Airport
SELECT * FROM STG_Flight