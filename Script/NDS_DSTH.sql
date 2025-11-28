CREATE DATABASE NDS_DATH
GO

USE NDS_DATH
GO

DROP TABLE IF EXISTS NDS_Flight;
GO
DROP TABLE IF EXISTS NDS_Distance;
GO
DROP TABLE IF EXISTS NDS_Airline;
GO
DROP TABLE IF EXISTS NDS_Airport;
GO
DROP TABLE IF EXISTS NDS_Reason;
GO

DROP TABLE IF EXISTS NDS_Time;
GO


CREATE TABLE NDS_Airline (
    Iata_Code VARCHAR(10) PRIMARY KEY,
    Airline_Name NVARCHAR(255),
    Created_Date DATETIME,
    Updated_Date DATETIME,    
);


CREATE TABLE NDS_Airport (
    Iata_Code VARCHAR(10) PRIMARY KEY,
    Airport_Name VARCHAR(255),
    City_Name VARCHAR(255),
    State_Code VARCHAR(50),
    Country_Name VARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
    Created_Date DATETIME,
    Updated_Date DATETIME
);


CREATE TABLE NDS_Reason (
    Reason_Id CHAR(1) PRIMARY KEY,
    Reason_Name NVARCHAR(255),
    Created_Date DATETIME,
    Updated_Date DATETIME
);



CREATE TABLE NDS_Time (
    Time_Id INT IDENTITY(1,1) PRIMARY KEY,
    Year_Value INT,
    Month_Value INT,
    Day_Value INT,
    Day_Of_Week VARCHAR(50),
	Created_Date DATETIME,
	Updated_Date DATETIME,
	CONSTRAINT UQ_NDS_Time_YearMonthDay
UNIQUE (Year_Value, Month_Value, Day_Value)
);


CREATE TABLE NDS_Flight (
    Iata_Airline VARCHAR(10),
    Flight_Number INT,
    Time_Id INT,
    Tail_Number VARCHAR(20),
    Origin_Airport VARCHAR(10),
    Destination_Airport VARCHAR(10),
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
    Cancellation_Reason CHAR(1),
    Created_Date DATETIME,
    Updated_Date DATETIME

    PRIMARY KEY (Iata_Airline, Flight_Number, Time_Id),

    FOREIGN KEY (Iata_Airline) REFERENCES NDS_Airline(Iata_Code),
    FOREIGN KEY (Origin_Airport) REFERENCES NDS_Airport(Iata_Code),
    FOREIGN KEY (Destination_Airport) REFERENCES NDS_Airport(Iata_Code),
    FOREIGN KEY (Time_Id) REFERENCES NDS_Time(Time_Id),
    FOREIGN KEY (Cancellation_Reason) REFERENCES NDS_Reason(Reason_Id)
);

CREATE TABLE NDS_Distance (
    Origin_Airport VARCHAR(10),
    Destination_Airport VARCHAR(10),
    Distance INT,
    Created_Date DATETIME,
    Updated_Date DATETIME,
    
    PRIMARY KEY (Origin_Airport, Destination_Airport),
    FOREIGN KEY (Origin_Airport) REFERENCES NDS_Airport(Iata_Code),
    FOREIGN KEY (Destination_Airport) REFERENCES NDS_Airport(Iata_Code)
);

SELECT * FROM NDS_Airline
SELECT * FROM NDS_Airport

SELECT * FROM NDS_Time
SELECT * FROM NDS_Distance

SELECT * FROM NDS_Reason