USE master;
GO

DROP DATABASE META_DATH
GO
CREATE DATABASE META_DATH
GO

USE META_DATH
GO


DROP TABLE IF EXISTS event_log;
GO
DROP TABLE IF EXISTS event_type;
GO
DROP TABLE IF EXISTS data_flow;
GO
DROP TABLE IF EXISTS status_table;
GO

DROP TABLE IF EXISTS dq_rule;
GO
DROP TABLE IF EXISTS dq_notification;
GO
DROP TABLE IF EXISTS usage_log;
GO

DROP TABLE IF EXISTS dq_rule_category;
GO
DROP TABLE IF EXISTS dq_rule_action;
GO
DROP TABLE IF EXISTS dw_user;
GO

DROP TABLE IF EXISTS ds_column;
GO
DROP TABLE IF EXISTS ds_table;
GO
DROP TABLE IF EXISTS ds_table_type;
GO

CREATE TABLE ds_table_type (
    table_type_key INT PRIMARY KEY IDENTITY(1,1),
    table_type VARCHAR(20) UNIQUE NOT NULL, 
    description NVARCHAR(255) NULL,
    create_timestamp DATETIME DEFAULT GETDATE() NULL,
    update_timestamp DATETIME DEFAULT GETDATE() NULL
);

CREATE TABLE ds_table (
    table_key INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) UNIQUE NOT NULL,
    entity_type INT NOT NULL,  
    data_store VARCHAR(20),            
    description NVARCHAR(255) NULL,
    create_timestamp DATETIME DEFAULT GETDATE() NULL,
    update_timestamp DATETIME DEFAULT GETDATE() NULL,

    FOREIGN KEY (entity_type) REFERENCES ds_table_type(table_type_key)
);

CREATE TABLE ds_column (
    column_key INT PRIMARY KEY IDENTITY(1,1),
    table_key INT NOT NULL,  
    column_name VARCHAR(255) NOT NULL,
    data_type VARCHAR(255) NOT NULL,
    is_PK BIT NULL DEFAULT 0,
    is_FK BIT NULL DEFAULT 0,
    is_null BIT NULL DEFAULT 1, 
    is_identity BIT NULL DEFAULT 0,
    create_timestamp DATETIME DEFAULT GETDATE() NULL,
    update_timestamp DATETIME DEFAULT GETDATE() NULL,

    
    FOREIGN KEY (table_key) REFERENCES ds_table(table_key),
	UNIQUE (table_key, column_name)
);


CREATE TABLE status_table (
    status_key INT PRIMARY KEY IDENTITY(1,1),
    status VARCHAR(50) UNIQUE NOT NULL,
      
    create_timestamp DATETIME DEFAULT GETDATE() NULL,
    update_timestamp DATETIME DEFAULT GETDATE() NULL
);

CREATE TABLE data_flow (
    data_flow_key INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) UNIQUE NOT NULL,
    description NVARCHAR(255) NULL,
    source VARCHAR(50) NULL,
    target VARCHAR(50) NULL,
    transformation NVARCHAR(MAX) NULL, 
    --Package INT NULL,    
    Status INT NULL,     
    LSET DATETIME NULL,  
    CET DATETIME NULL,   
    create_timestamp DATETIME DEFAULT GETDATE() NULL,
    update_timestamp DATETIME DEFAULT GETDATE() NULL,

    FOREIGN KEY (status) REFERENCES status_table(status_key),
);

CREATE TABLE event_type (
    event_type_key INT PRIMARY KEY IDENTITY(1,1),
    event_type NVARCHAR(255) UNIQUE NOT NULL 
);

CREATE TABLE event_log (
    log_key INT PRIMARY KEY IDENTITY(1,1),
    event_type INT NOT NULL, 
    timestamp DATETIME DEFAULT GETDATE(),
    object INT NULL,              
    rows INT NULL,
    note VARCHAR(MAX) NULL,
    data_flow INT NULL,
    
    
    FOREIGN KEY (event_type) REFERENCES event_type(event_type_key),
    FOREIGN KEY (data_flow) REFERENCES data_flow(data_flow_key),
	FOREIGN KEY (object) REFERENCES ds_table(table_key)
);

---------------------------------------------------------
-- 1. ds_table_type
---------------------------------------------------------
INSERT INTO ds_table_type (table_type, description)
VALUES
('Dimension', N'Dimension table'),
('Fact', N'Fact table'),
('Master', N'Master table'),
('Transaction', N'Transaction table'),
('Stage', N'Stage table'),
('Metadata', N'Metadata table');
INSERT INTO ds_table_type (table_type, description)
VALUES 
('Cube', N'SSAS OLAP Cube'),
('Dashboard', N'Power BI / Excel Dashboard');
---------------------------------------------------------

---------------------------------------------------------
-- 2. ds_table  (khai báo stage + nds)
---------------------------------------------------------
INSERT INTO ds_table (name, entity_type, data_store, description)
VALUES
('STG_Airline', 5, 'STAGE', N'Stage Airlines'),
('STG_Airport', 5, 'STAGE', N'Stage Airport'),
('STG_Flight',  5, 'STAGE', N'Stage Flight'),
('STG_AirportCodeMapping',  5, 'STAGE', N'Stage Airport Code mapping between DOT and IATA'),
('STG_Flight_DOT',  5, 'STAGE', N'Stage for flight using DOT in the Destination and Origin airport'),

('NDS_Airline', 3, 'NDS', N'NDS Airline'),
('NDS_Airport', 3, 'NDS', N'NDS Airport'),
('NDS_Reason',  3, 'NDS', N'NDS Delay Reason'),
('NDS_Time',    3, 'NDS', N'NDS Date'),
('NDS_Flight',  4, 'NDS', N'NDS Detail Flight'),
('NDS_Distance',3, 'NDS', N'NDS Airport Distance');

-- Khai báo Cube và Dashboard
-- Cột data_store để đánh dấu nơi dữ liệu thực sự nằm
INSERT INTO ds_table (name, entity_type, data_store, description)
VALUES 
('DDS_DATH_CUBE',7 , 'SSAS', N'Aviation OLAP Cube'),
('FLIGHT_ANALYSIS_DASHBOARD', 8, 'PowerBI', N'Dashboard connect live to Cube');
---------------------------------------------------------

---------------------------------------------------------
-- 3. ds_column 
---------------------------------------------------------
-- Lấy key bảng để gán fk
DECLARE @STG_Airline INT = (SELECT table_key FROM ds_table WHERE name='STG_Airline');
DECLARE @STG_Airport INT = (SELECT table_key FROM ds_table WHERE name='STG_Airport');
DECLARE @STG_Flight  INT = (SELECT table_key FROM ds_table WHERE name='STG_Flight');
DECLARE @STG_AirportCodeMapping INT = (SELECT table_key FROM ds_table WHERE name='STG_AirportCodeMapping');
DECLARE @STG_Flight_DOT INT         = (SELECT table_key FROM ds_table WHERE name='STG_Flight_DOT');


DECLARE @NDS_Airline INT  = (SELECT table_key FROM ds_table WHERE name='NDS_Airline');
DECLARE @NDS_Airport INT  = (SELECT table_key FROM ds_table WHERE name='NDS_Airport');
DECLARE @NDS_Reason  INT  = (SELECT table_key FROM ds_table WHERE name='NDS_Reason');
DECLARE @NDS_Time    INT  = (SELECT table_key FROM ds_table WHERE name='NDS_Time');
DECLARE @NDS_Flight  INT  = (SELECT table_key FROM ds_table WHERE name='NDS_Flight');
DECLARE @NDS_Distance INT = (SELECT table_key FROM ds_table WHERE name='NDS_Distance');

---------------------------------------------------------
-- STAGE: Airline
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type)
VALUES
(@STG_Airline, 'Iata_Code', 'CHAR(2)'),
(@STG_Airline, 'Airline', 'NVARCHAR(255)');

---------------------------------------------------------
-- STAGE: Airport
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type)
VALUES
(@STG_Airport, 'Iata_Code', 'CHAR(3)'),
(@STG_Airport, 'Airport_Name', 'VARCHAR(255)'),
(@STG_Airport, 'City_Name', 'VARCHAR(255)'),
(@STG_Airport, 'State_Code', 'VARCHAR(50)'),
(@STG_Airport, 'Country_Name', 'VARCHAR(50)'),
(@STG_Airport, 'Latitude', 'FLOAT'),
(@STG_Airport, 'Longitude', 'FLOAT');

---------------------------------------------------------
-- STAGE: Flight
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type)
VALUES
(@STG_Flight, 'Year_Value', 'INT'),
(@STG_Flight, 'Month_Value', 'INT'),
(@STG_Flight, 'Day_Value', 'INT'),
(@STG_Flight, 'Day_Of_Week', 'INT'),
(@STG_Flight, 'Iata_Airline', 'CHAR(2)'),
(@STG_Flight, 'Flight_Number', 'INT'),
(@STG_Flight, 'Time_Id', 'INT'),
(@STG_Flight, 'Tail_Number', 'VARCHAR(20)'),
(@STG_Flight, 'Origin_Airport', 'VARCHAR(5)'),
(@STG_Flight, 'Destination_Airport', 'VARCHAR(5)'),
(@STG_Flight, 'Distance', 'INT'),
(@STG_Flight, 'Scheduled_Departure', 'TIME'),
(@STG_Flight, 'Departure_Time', 'TIME'),
(@STG_Flight, 'Departure_Delay', 'INT'),
(@STG_Flight, 'Taxi_Out', 'INT'),
(@STG_Flight, 'Wheels_Off', 'TIME'),
(@STG_Flight, 'Scheduled_Time', 'INT'),
(@STG_Flight, 'Elapsed_Time', 'INT'),
(@STG_Flight, 'Air_Time', 'INT'),
(@STG_Flight, 'Wheels_On', 'TIME'),
(@STG_Flight, 'Taxi_In', 'INT'),
(@STG_Flight, 'Scheduled_Arrival', 'TIME'),
(@STG_Flight, 'Arrival_Time', 'TIME'),
(@STG_Flight, 'Arrival_Delay', 'INT'),
(@STG_Flight, 'Diverted', 'BIT'),
(@STG_Flight, 'Cancelled', 'BIT'),
(@STG_Flight, 'Air_System_Delay', 'INT'),
(@STG_Flight, 'Security_Delay', 'INT'),
(@STG_Flight, 'Airline_Delay', 'INT'),
(@STG_Flight, 'Late_Aircraft_Delay', 'INT'),
(@STG_Flight, 'Weather_Delay', 'INT'),
(@STG_Flight, 'Cancellation_Reason', 'CHAR(1)');

---------------------------------------------------------
-- STAGE: AirportCodeMapping
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type)
VALUES
(@STG_AirportCodeMapping, 'DOT_Code', 'VARCHAR(5)'),
(@STG_AirportCodeMapping, 'IATA_CODE', 'VARCHAR(3)');


---------------------------------------------------------
-- STAGE: Flight_DOT
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type)
VALUES
(@STG_Flight_DOT, 'Air_System_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'Air_Time_Fix', 'INT'),
(@STG_Flight_DOT, 'Airline_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'Airline_Fix', 'VARCHAR(2)'),
(@STG_Flight_DOT, 'Arrival_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'Arrival_Time_Fix', 'DATETIME'), 
(@STG_Flight_DOT, 'Cancellation_Reason_Fix', 'VARCHAR(1)'),
(@STG_Flight_DOT, 'Cancelled_Fix', 'BIT'),
(@STG_Flight_DOT, 'DAY_Fix', 'INT'),
(@STG_Flight_DOT, 'DAY_OF_WEEK_Fix', 'INT'),
(@STG_Flight_DOT, 'Departure_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'Departure_Time_Fix', 'DATETIME'), 
(@STG_Flight_DOT, 'Destination_Airport_Fix', 'VARCHAR(5)'),
(@STG_Flight_DOT, 'DISTANCE_Fix', 'INT'),
(@STG_Flight_DOT, 'DIVERTED_Fix', 'BIT'),
(@STG_Flight_DOT, 'Elapsed_Time_Fix', 'INT'),
(@STG_Flight_DOT, 'FLIGHT_NUMBER_Fix', 'INT'),
(@STG_Flight_DOT, 'Late_Aircraft_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'MONTH_Fix', 'INT'),
(@STG_Flight_DOT, 'Origin_Airport_Fix', 'VARCHAR(5)'),
(@STG_Flight_DOT, 'Scheduled_Arrival_Fix', 'DATETIME'), 
(@STG_Flight_DOT, 'Scheduled_Departure_Fix', 'DATETIME'), 
(@STG_Flight_DOT, 'Scheduled_Time_Fix', 'INT'),
(@STG_Flight_DOT, 'Security_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'Tail_Number_Fix', 'VARCHAR(20)'),
(@STG_Flight_DOT, 'Taxi_In_Fix', 'INT'),
(@STG_Flight_DOT, 'Taxi_Out_Fix', 'INT'),
(@STG_Flight_DOT, 'Weather_Delay_Fix', 'INT'),
(@STG_Flight_DOT, 'Wheels_Off_Fix', 'DATETIME'), 
(@STG_Flight_DOT, 'Wheels_On_Fix', 'DATETIME'), 
(@STG_Flight_DOT, 'YEAR_Fix', 'INT');


---------------------------------------------------------
-- NDS: Airline
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@NDS_Airline, 'Iata_Code', 'VARCHAR(10)', 1),
(@NDS_Airline, 'Airline_Name', 'NVARCHAR(255)', 0),
(@NDS_Airline, 'Created_Date', 'DATETIME', 0),
(@NDS_Airline, 'Updated_Date', 'DATETIME', 0);

---------------------------------------------------------
-- NDS: Airport
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@NDS_Airport, 'Iata_Code', 'VARCHAR(10)', 1),
(@NDS_Airport, 'Airport_Name', 'VARCHAR(255)', 0),
(@NDS_Airport, 'City_Name', 'VARCHAR(255)', 0),
(@NDS_Airport, 'State_Code', 'VARCHAR(50)', 0),
(@NDS_Airport, 'Country_Name', 'VARCHAR(50)', 0),
(@NDS_Airport, 'Latitude', 'FLOAT', 0),
(@NDS_Airport, 'Longitude', 'FLOAT', 0),
(@NDS_Airport, 'Created_Date', 'DATETIME', 0),
(@NDS_Airport, 'Updated_Date', 'DATETIME', 0);

---------------------------------------------------------
-- NDS: Reason
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@NDS_Reason, 'Reason_Id', 'CHAR(1)', 1),
(@NDS_Reason, 'Reason_Name', 'NVARCHAR(255)', 0),
(@NDS_Reason, 'Created_Date', 'DATETIME', 0),
(@NDS_Reason, 'Updated_Date', 'DATETIME', 0);

---------------------------------------------------------
-- NDS: Time
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type, is_PK, is_identity)
VALUES
(@NDS_Time, 'Time_Id', 'INT', 1, 1),
(@NDS_Time, 'Year_Value', 'INT', 0, 0),
(@NDS_Time, 'Month_Value', 'INT', 0, 0),
(@NDS_Time, 'Day_Value', 'INT', 0, 0),
(@NDS_Time, 'Day_Of_Week', 'VARCHAR(50)', 0, 0),
(@NDS_Time, 'Created_Date', 'DATETIME', 0, 0),
(@NDS_Time, 'Updated_Date', 'DATETIME', 0, 0);

---------------------------------------------------------
-- NDS: Distance
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@NDS_Distance, 'Origin_Airport', 'VARCHAR(10)', 1),
(@NDS_Distance, 'Destination_Airport', 'VARCHAR(10)', 1),
(@NDS_Distance, 'Distance', 'INT', 0),
(@NDS_Distance, 'Created_Date', 'DATETIME', 0),
(@NDS_Distance, 'Updated_Date', 'DATETIME', 0);

---------------------------------------------------------
-- NDS: Flight
---------------------------------------------------------
INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@NDS_Flight, 'Iata_Airline', 'VARCHAR(10)', 1),
(@NDS_Flight, 'Flight_Number', 'INT', 1),
(@NDS_Flight, 'Time_Id', 'INT', 1),
(@NDS_Flight, 'Tail_Number', 'VARCHAR(20)', 0),
(@NDS_Flight, 'Origin_Airport', 'VARCHAR(10)', 0),
(@NDS_Flight, 'Destination_Airport', 'VARCHAR(10)', 0),
(@NDS_Flight, 'Scheduled_Departure', 'INT', 0),
(@NDS_Flight, 'Departure_Delay', 'INT', 0),
(@NDS_Flight, 'Taxi_Out', 'INT', 0),
(@NDS_Flight, 'Wheels_Off', 'INT', 0),
(@NDS_Flight, 'Scheduled_Time', 'INT', 0),
(@NDS_Flight, 'Air_Time', 'INT', 0),
(@NDS_Flight, 'Wheels_On', 'INT', 0),
(@NDS_Flight, 'Taxi_In', 'INT', 0),
(@NDS_Flight, 'Scheduled_Arrival', 'INT', 0),
(@NDS_Flight, 'Arrival_Delay', 'INT', 0),
(@NDS_Flight, 'Diverted', 'BIT', 0),
(@NDS_Flight, 'Cancelled', 'BIT', 0),
(@NDS_Flight, 'Air_System_Delay', 'INT', 0),
(@NDS_Flight, 'Security_Delay', 'INT', 0),
(@NDS_Flight, 'Airline_Delay', 'INT', 0),
(@NDS_Flight, 'Late_Aircraft_Delay', 'INT', 0),
(@NDS_Flight, 'Weather_Delay', 'INT', 0),
(@NDS_Flight, 'Cancellation_Reason', 'CHAR(1)', 0),
(@NDS_Flight, 'Created_Date', 'DATETIME', 0),
(@NDS_Flight, 'Updated_Date', 'DATETIME', 0);

---------------------------------------------------------
-- 4. status_table
---------------------------------------------------------
INSERT INTO status_table (status)
VALUES ('PENDING'), ('RUNNING'), ('SUCCESS'), ('FAILED'), ('WARNING');

---------------------------------------------------------
-- 5. data_flow
---------------------------------------------------------
INSERT INTO data_flow (name, description, source, target, transformation, status, LSET, CET)
VALUES
-- Source -> Stage (giữ nguyên)
('DF_SRC_AIRLINE_TO_STG', 'Extract Airline from source to STAGE', 'SOURCE', 'STAGE', 'Extract + Clean', 3, '2010-01-01 00:00:00', '2010-01-01 00:30:00'),
('DF_SRC_AIRPORT_TO_STG', 'Extract Airport from source to STAGE', 'SOURCE', 'STAGE', 'Extract + Clean', 3, '2010-01-01 01:00:00', '2010-01-01 01:30:00'),
('DF_SRC_FLIGHT_TO_STG', 'Extract Flight from source to STAGE', 'SOURCE', 'STAGE', 'Extract + Clean', 3, '2010-01-01 02:00:00', '2010-01-01 02:30:00'),

-- Stage -> NDS 
('DF_STG_AIRLINE_TO_NDS', 'Load Airline', 'STAGE', 'NDS', 'Clean + Insert', 3, '2010-01-01 00:00:00', '2010-01-01 01:00:00'),
('DF_STG_AIRPORT_TO_NDS', 'Load Airport', 'STAGE', 'NDS', 'Clean + Insert', 3, '2010-01-01 02:00:00', '2010-01-01 03:00:00'),
('DF_STG_FLIGHT_TO_NDS_FLIGHT', 'Load Flight details', 'STAGE', 'NDS_Flight', 'Transform + Insert', 3, '2010-01-02 00:00:00', '2010-01-02 01:00:00'),
('DF_STG_FLIGHT_TO_NDS_DISTANCE', 'Load Flight distance', 'STAGE', 'NDS_Distance', 'Transform + Insert', 3, '2010-01-02 01:00:00', '2010-01-02 01:30:00');

USE META_DATH;
GO

---------------------------------------------------------
-- DDS TABLES
---------------------------------------------------------
INSERT INTO ds_table (name, entity_type, data_store, description)
VALUES
('DIM_DATE', 1, 'DDS', N'Dimension Date'),
('DIM_AIRLINE', 1, 'DDS', N'Dimension Airline'),
('DIM_AIRPORT', 1, 'DDS', N'Dimension Airport'),
('DIM_REASON', 1, 'DDS', N'Dimension Delay / Cancellation Reason'),
('DIM_TIME_OF_DAY', 1, 'DDS', N'Dimension Time of Day'),
('FACT_FLIGHT', 2, 'DDS', N'Fact Flight Performance');

DECLARE @DIM_DATE INT = (SELECT table_key FROM ds_table WHERE name='DIM_DATE');
DECLARE @DIM_AIRLINE INT = (SELECT table_key FROM ds_table WHERE name='DIM_AIRLINE');
DECLARE @DIM_AIRPORT INT = (SELECT table_key FROM ds_table WHERE name='DIM_AIRPORT');
DECLARE @DIM_REASON INT = (SELECT table_key FROM ds_table WHERE name='DIM_REASON');
DECLARE @DIM_TIME_OF_DAY INT = (SELECT table_key FROM ds_table WHERE name='DIM_TIME_OF_DAY');
DECLARE @FACT_FLIGHT INT = (SELECT table_key FROM ds_table WHERE name='FACT_FLIGHT');

INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@DIM_DATE, 'Date_Key', 'INT', 1),
(@DIM_DATE, 'Full_Date', 'DATE', 0),
(@DIM_DATE, 'Year', 'INT', 0),
(@DIM_DATE, 'Quarter', 'INT', 0),
(@DIM_DATE, 'Month', 'INT', 0),
(@DIM_DATE, 'Month_Name', 'VARCHAR(20)', 0),
(@DIM_DATE, 'Day', 'INT', 0),
(@DIM_DATE, 'Day_Of_Week', 'INT', 0),
(@DIM_DATE, 'Day_Name', 'VARCHAR(20)', 0),
(@DIM_DATE, 'Is_Weekend', 'BIT', 0),
(@DIM_DATE, 'Season', 'VARCHAR(20)', 0),
(@DIM_DATE, 'CREATED_DATE', 'DATETIME', 0),
(@DIM_DATE, 'UPDATED_DATE', 'DATETIME', 0);

INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@DIM_AIRLINE, 'Airline_Key', 'INT', 1),
(@DIM_AIRLINE, 'IATA_Code', 'CHAR(2)', 0),
(@DIM_AIRLINE, 'Airline_Name', 'NVARCHAR(255)', 0),
(@DIM_AIRLINE, 'Is_Active', 'BIT', 0),
(@DIM_AIRLINE, 'CREATED_DATE', 'DATETIME', 0),
(@DIM_AIRLINE, 'UPDATED_DATE', 'DATETIME', 0);

INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@DIM_AIRPORT, 'Airport_Key', 'INT', 1),
(@DIM_AIRPORT, 'IATA_Code', 'CHAR(3)', 0),
(@DIM_AIRPORT, 'Airport_Name', 'VARCHAR(255)', 0),
(@DIM_AIRPORT, 'City', 'VARCHAR(255)', 0),
(@DIM_AIRPORT, 'State', 'VARCHAR(50)', 0),
(@DIM_AIRPORT, 'Country', 'VARCHAR(50)', 0),
(@DIM_AIRPORT, 'Latitude', 'FLOAT', 0),
(@DIM_AIRPORT, 'Longitude', 'FLOAT', 0),
(@DIM_AIRPORT, 'CREATED_DATE', 'DATETIME', 0),
(@DIM_AIRPORT, 'UPDATED_DATE', 'DATETIME', 0);

INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@DIM_REASON, 'Reason_Key', 'INT', 1),
(@DIM_REASON, 'Reason_Code', 'CHAR(1)', 0),
(@DIM_REASON, 'Reason_Description', 'NVARCHAR(255)', 0),
(@DIM_REASON, 'CREATED_DATE', 'DATETIME', 0),
(@DIM_REASON, 'UPDATED_DATE', 'DATETIME', 0);

INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@DIM_TIME_OF_DAY, 'Time_Of_Day_Key', 'INT', 1),
(@DIM_TIME_OF_DAY, 'Hour', 'INT', 0),
(@DIM_TIME_OF_DAY, 'Time_Of_Day_Name', 'VARCHAR(50)', 0),
(@DIM_TIME_OF_DAY, 'CREATED_DATE', 'DATETIME', 0),
(@DIM_TIME_OF_DAY, 'UPDATED_DATE', 'DATETIME', 0);

INSERT INTO ds_column (table_key, column_name, data_type, is_PK)
VALUES
(@FACT_FLIGHT, 'FlightID', 'INT', 1),
(@FACT_FLIGHT, 'Date_Key', 'INT', 0),
(@FACT_FLIGHT, 'Airline_Key', 'INT', 0),
(@FACT_FLIGHT, 'Origin_Airport_Key', 'INT', 0),
(@FACT_FLIGHT, 'Dest_Airport_Key', 'INT', 0),
(@FACT_FLIGHT, 'Reason_Key', 'INT', 0),
(@FACT_FLIGHT, 'Time_Of_Day_Key', 'INT', 0),

(@FACT_FLIGHT, 'Flight_Number', 'INT', 0),
(@FACT_FLIGHT, 'Tail_Number', 'VARCHAR(20)', 0),

(@FACT_FLIGHT, 'Flight_Count', 'INT', 0),
(@FACT_FLIGHT, 'Dep_Delay_Minutes', 'INT', 0),
(@FACT_FLIGHT, 'Arr_Delay_Minutes', 'INT', 0),


(@FACT_FLIGHT, 'Is_Cancelled', 'INT', 0),
(@FACT_FLIGHT, 'Is_Diverted', 'INT', 0),
(@FACT_FLIGHT, 'Is_OTP', 'INT', 0),
(@FACT_FLIGHT, 'Is_Delayed', 'INT', 0),

(@FACT_FLIGHT, 'Air_System_Delay', 'INT', 0),
(@FACT_FLIGHT, 'Security_Delay', 'INT', 0),
(@FACT_FLIGHT, 'Airline_Delay', 'INT', 0),
(@FACT_FLIGHT, 'Late_Aircraft_Delay', 'INT', 0),
(@FACT_FLIGHT, 'Weather_Delay', 'INT', 0),

(@FACT_FLIGHT, 'CREATED_DATE', 'DATETIME', 0),
(@FACT_FLIGHT, 'UPDATED_DATE', 'DATETIME', 0);

INSERT INTO data_flow (name, description, source, target, transformation, status)
VALUES
('DF_NDS_TO_DIM', 'Load NDS to Dimension tables', 'NDS', 'DDS_DIM', 'Surrogate Key + SCD', 3),
('DF_NDS_TO_FACT', 'Load NDS to Fact Flight Performance', 'NDS', 'DDS_FACT', 'Star Schema Transform', 3);

INSERT INTO data_flow (name, description, source, target, transformation, status, LSET, CET)
VALUES
('DF_NDS_TO_DIM_AIRLINE',
 'Load data from NDS_AIRLINE to DIM_AIRLINE (SCD Type 2)',
 'NDS_AIRLINE',
 'DIM_AIRLINE',
 'Surrogate Key + SCD Type 2',
 3,
 '2010-01-02 02:00:00',
 '2010-01-02 02:20:00'),
('DF_NDS_TO_DIM_AIRPORT',
 'Load data from NDS_AIRPORT to DIM_AIRPORT (SCD Type 2)',
 'NDS_AIRPORT',
 'DIM_AIRPORT',
 'Surrogate Key + SCD Type 2',
 3,
 '2010-01-02 02:20:00',
 '2010-01-02 02:45:00'),
 ('DF_NDS_TO_DIM_REASON',
 'Load data from NDS_REASON to DIM_REASON (SCD Type 2)',
 'NDS_REASON',
 'DIM_REASON',
 'Surrogate Key',
 3,
 '2010-01-02 02:45:00',
 '2010-01-02 03:00:00'),
('DF_NDS_TO_FACT_FLIGHT',
 'Load data from NDS_FLIGHT to FACT_FLIGHT',
 'NDS_FLIGHT',
 'FACT_FLIGHT',
 'Star Schema Transform',
 3,
 '2010-01-02 03:00:00',
 '2010-01-02 04:00:00');


USE META_DATH;
GO


-- DATA QUALITY METADATA TABLES
---------------------------------------------------------
-- Danh mục kiểm tra
CREATE TABLE dq_rule_category (
    category_id CHAR(1) PRIMARY KEY,
    description VARCHAR(100)
);
INSERT INTO dq_rule_category VALUES 
('I', 'Incoming data validation (Stage)'),
('C', 'Cross reference validation (NDS)'),
('D', 'Internal data warehouse validation (DDS)');


-- Hành động xử lý: R (Reject), A (Allow), F (Fix)
CREATE TABLE dq_rule_action (
    action_id CHAR(1) PRIMARY KEY,
    description VARCHAR(50)
);
INSERT INTO dq_rule_action VALUES ('R', 'Reject Record'), ('A', 'Allow with Warning'), ('F', 'Auto Fix');

---------------------------------------------------------
-- BẢNG THÔNG TIN NGƯỜI DÙNG & NHÓM
---------------------------------------------------------

CREATE TABLE dw_user (
    user_key INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    department NVARCHAR(100),
    role NVARCHAR(100),
    email_address VARCHAR(255),
    user_group_key INT -- Để gom nhóm nhận thông báo
);

INSERT INTO dw_user (name, department, role, email_address, user_group_key)
VALUES 
(N'Phạm Khánh Hân', 'Data Engineering', 'DE', '22120091.@student.hcmus.edu.vn', 2),
(N'Nguyễn Thị Tú Ngọc', 'Data Engineering', 'DE', '22120233.@student.hcmus.edu.vn', 2),
(N'Quách Quỳnh Như', 'Data Engineering', 'DE', '22120258.@student.hcmus.edu.vn', 2),
(N'Dương Kim Phụng', 'Data Engineering', 'DE', '22120284.@student.hcmus.edu.vn', 2);

---------------------------------------------------------
-- BẢNG QUY TẮC DQ (DQ_RULE)
---------------------------------------------------------

CREATE TABLE dq_rule (
    rule_key INT IDENTITY(1,1) PRIMARY KEY,
    rule_name NVARCHAR(255),
    description NVARCHAR(MAX),
    rule_type CHAR(1),
    rule_category CHAR(1) FOREIGN KEY REFERENCES dq_rule_category(category_id),
    risk_level INT CHECK (risk_level BETWEEN 1 AND 5),
    status VARCHAR(7) DEFAULT 'Active', -- Active, Inactive
    action CHAR(1) FOREIGN KEY REFERENCES dq_rule_action(action_id),
    
    -- Liên kết với hệ thống hiện tại của bạn
    table_key INT FOREIGN KEY REFERENCES ds_table(table_key), 
    
    create_timestamp DATETIME DEFAULT GETDATE(),
    update_timestamp DATETIME DEFAULT GETDATE()
);

---------------------------------------------------------
-- BẢNG THÔNG BÁO (DQ_NOTIFICATION)
---------------------------------------------------------

CREATE TABLE dq_notification (
    notification_key INT IDENTITY(1,1) PRIMARY KEY,
    rule_key INT FOREIGN KEY REFERENCES dq_rule(rule_key),
    recipient_type CHAR(1), -- I (Individual), G (Group)
    recipient_id INT,       -- ID của user / group
    method CHAR(1),         -- E (Email), S (SMS)
    last_notified DATETIME
);

---------------------------------------------------------
-- DATA
---------------------------------------------------------

DECLARE @tbl_STG_Airport INT = (SELECT table_key FROM ds_table WHERE name='STG_Airport');
DECLARE @tbl_NDS_Flight INT = (SELECT table_key FROM ds_table WHERE name='NDS_Flight');

INSERT INTO dq_rule (rule_name, description, rule_type, rule_category, risk_level, action, table_key)
VALUES 
-- Quy tắc 1: Kiểm tra mã IATA Sân bay (3 ký tự chữ)
(N'VAL_IATA_AIRPORT', N'IATA Airport code must be exactly 3 uppercase letters', 'E', 'I', 4, 'R', @tbl_STG_Airport),

-- Quy tắc 2: Kiểm tra tính logic của thời gian (Delay không được âm)
(N'VAL_DELAY_POSITIVE', N'Departure delay should not be negative in NDS', 'W', 'C', 2, 'A', @tbl_NDS_Flight),

-- Quy tắc 3: Kiểm tra tính nhất quán mã Airline (Phải tồn tại trong DIM_AIRLINE)
(N'REF_AIRLINE_EXIST', N'Airline code must exist in Dimension Airline before loading Fact', 'E', 'D', 5, 'R', @tbl_NDS_Flight);

-- Thiết lập thông báo cho Quy tắc 1 gửi cho Admin Duy
INSERT INTO dq_notification (rule_key, recipient_type, recipient_id, method)
VALUES (1, 'I', 1, 'E');

GO

---------------------------------------------------------
-- USAGE METADATA TABLE
---------------------------------------------------------
CREATE TABLE usage_log (
    usage_key INT IDENTITY(1,1) PRIMARY KEY,
    user_key INT FOREIGN KEY REFERENCES dw_user(user_key),
    object_key INT FOREIGN KEY REFERENCES ds_table(table_key), -- Dashboard hoặc Cube
    
    access_via NVARCHAR(50), -- 'Power BI', 'Excel', 'SSMS (MDX Query)'
    
    timestamp DATETIME DEFAULT GETDATE(),
);

-- Data
DECLARE @uHanh INT = (SELECT user_key FROM dw_user WHERE name LIKE N'%Khánh Hân%');
DECLARE @uNgoc INT = (SELECT user_key FROM dw_user WHERE name LIKE N'%Tú Ngọc%');

DECLARE @objCube INT = (SELECT table_key FROM ds_table WHERE name = 'DDS_DATH_CUBE');
DECLARE @objDash INT = (SELECT table_key FROM ds_table WHERE name = 'FLIGHT_ANALYSIS_DASHBOARD');

INSERT INTO usage_log (user_key, object_key, access_via, timestamp)
VALUES 
-- Trường hợp 1: Người dùng mở Dashboard (Dashboard tự động gọi Cube)
(@uHanh, @objDash, 'Power BI', GETDATE()),

-- Trường hợp 2: Người dùng dùng Excel kết nối trực tiếp vào Cube để kéo Pivot table
(@uNgoc, @objCube, 'Excel Pivot', GETDATE());