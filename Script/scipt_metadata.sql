USE META_DATH;
GO

---------------------------------------------------------
-- 1. ds_table_type
---------------------------------------------------------
INSERT INTO ds_table_type (table_type, description)
VALUES
('SOURCE', N'Data nguồn'),
('STAGE', N'Data stage'),
('NDS', N'Normalized Data Store'),
('DDS', N'Dimensional Data Store');
--('REFERENCE', N'Data danh mục');
---------------------------------------------------------

---------------------------------------------------------
-- 2. ds_table  (khai báo stage + nds)
---------------------------------------------------------
INSERT INTO ds_table (name, entity_type, data_store, description)
VALUES
('STG_Airline', 2, 'SQL', N'Stage Airlines'),
('STG_Airport', 2, 'SQL', N'Stage Airport'),
('STG_Flight',  2, 'SQL', N'Stage Flight'),

('NDS_Airline', 3, 'SQL', N'NDS Airline'),
('NDS_Airport', 3, 'SQL', N'NDS Airport'),
('NDS_Reason',  3, 'SQL', N'NDS Delay Reason'),
('NDS_Time',    3, 'SQL', N'NDS Date'),
('NDS_Flight',  3, 'SQL', N'NDS Detail Flight'),
('NDS_Distance',3, 'SQL', N'NDS Airport Distance');
---------------------------------------------------------

---------------------------------------------------------
-- 3. ds_column 
---------------------------------------------------------
-- Lấy key bảng để gán fk
DECLARE @STG_Airline INT = (SELECT table_key FROM ds_table WHERE name='STG_Airline');
DECLARE @STG_Airport INT = (SELECT table_key FROM ds_table WHERE name='STG_Airport');
DECLARE @STG_Flight  INT = (SELECT table_key FROM ds_table WHERE name='STG_Flight');

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
(@STG_Flight, 'Origin_Airport', 'CHAR(3)'),
(@STG_Flight, 'Destination_Airport', 'CHAR(3)'),
(@STG_Flight, 'Distance', 'INT'),
(@STG_Flight, 'Scheduled_Departure', 'INT'),
(@STG_Flight, 'Departure_Time', 'INT'),
(@STG_Flight, 'Departure_Delay', 'INT'),
(@STG_Flight, 'Taxi_Out', 'INT'),
(@STG_Flight, 'Wheels_Off', 'INT'),
(@STG_Flight, 'Scheduled_Time', 'INT'),
(@STG_Flight, 'Elapsed_Time', 'INT'),
(@STG_Flight, 'Air_Time', 'INT'),
(@STG_Flight, 'Wheels_On', 'INT'),
(@STG_Flight, 'Taxi_In', 'INT'),
(@STG_Flight, 'Scheduled_Arrival', 'INT'),
(@STG_Flight, 'Arrival_Time', 'INT'),
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
(@NDS_Flight, 'Departure_Time', 'INT', 0),
(@NDS_Flight, 'Departure_Delay', 'INT', 0),
(@NDS_Flight, 'Taxi_Out', 'INT', 0),
(@NDS_Flight, 'Wheels_Off', 'INT', 0),
(@NDS_Flight, 'Scheduled_Time', 'INT', 0),
(@NDS_Flight, 'Elapsed_Time', 'INT', 0),
(@NDS_Flight, 'Air_Time', 'INT', 0),
(@NDS_Flight, 'Wheels_On', 'INT', 0),
(@NDS_Flight, 'Taxi_In', 'INT', 0),
(@NDS_Flight, 'Scheduled_Arrival', 'INT', 0),
(@NDS_Flight, 'Arrival_Time', 'INT', 0),
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


---------------------------------------------------------
-- 6. event_type
---------------------------------------------------------
--INSERT INTO event_type (event_type)
--VALUES ('START'),('END'),('INFO'),('ERROR'),('ROW_COUNT');

INSERT INTO event_type (event_type)
VALUES 
('Error'),
('Load Stage Airline'),
('Load Stage Airport'),
('Load Stage Flight'),

('Load NDS Airline'),
('Load NDS Airport'),
('Load NDS Reason'),
('Load NDS Time'),
('Load NDS Distance'),
('Load NDS Flight');

-----------------------------------------------------------
---- 7. event_log
-----------------------------------------------------------
--INSERT INTO event_log (event_type, timestamp, object, rows, note, data_flow)
--VALUES
--(1, GETDATE(), 1, NULL, 'Start load airline', 1),
--(5, GETDATE(), 1, 3, 'Loaded Airline rows', 1),
--(2, GETDATE(), 1, NULL, 'End load airline', 1);
