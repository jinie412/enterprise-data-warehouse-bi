CREATE DATABASE DDS_DATH;
GO

USE DDS_DATH;
GO

DROP TABLE IF EXISTS FACT_FLIGHT;

DROP TABLE IF EXISTS DIM_TIME_OF_DAY;
DROP TABLE IF EXISTS DIM_REASON;
DROP TABLE IF EXISTS DIM_AIRPORT;
DROP TABLE IF EXISTS DIM_AIRLINE;
DROP TABLE IF EXISTS DIM_DATE;
GO

-- Bảng Dim_Date
-- Phân tích theo ngày / tháng / quý / năm / mùa / cuối tuần

CREATE TABLE DIM_DATE (
    Date_Key INT PRIMARY KEY,
	Full_Date DATE,
	Year INT,
	Quarter INT,
	Month INT,
	Month_Name VARCHAR(20), -- Tên tháng (January, February…), hiển thị trên biểu đồ BI
	Day INT,
	Day_Of_Week INT, -- Thứ trong tuần (1=Chủ nhật, 2=Thứ 2…)
	Day_Name VARCHAR(20), -- Tên thứ (Monday, Tuesday…)
	Is_Weekend BIT, -- 1: Cuối tuần, 0: Ngày thường
	Season VARCHAR(20),
	CREATED_DATE DATETIME DEFAULT GETDATE(),
	UPDATED_DATE DATETIME DEFAULT GETDATE()
);

-- Bảng Dim_Airline
-- Phân tích OTP (viết tắt của On-Time Performance – chỉ số đánh giá mức độ đúng giờ của chuyến bay), 
-- số chuyến, delay theo hãng

CREATE TABLE DIM_AIRLINE (
    Airline_Key INT IDENTITY(1,1) PRIMARY KEY,
	IATA_Code CHAR(2) NOT NULL,
	Airline_Name NVARCHAR(255),
	Is_Active BIT  DEFAULT 1,
	CREATED_DATE DATETIME DEFAULT GETDATE(),
	UPDATED_DATE DATETIME DEFAULT GETDATE()
);

-- Bảng Dim_Airport (có chiều sân bay)

CREATE TABLE DIM_AIRPORT (
    Airport_Key INT IDENTITY(1,1) PRIMARY KEY,
	IATA_Code CHAR(3) NOT NULL,
	Airport_Name VARCHAR(255),
	City VARCHAR(255),
	State VARCHAR(50),
	Country VARCHAR(50),
	Latitude FLOAT, -- Vĩ độ
	Longitude FLOAT, -- Kinh độ
	Is_Active BIT  DEFAULT 1,
	CREATED_DATE DATETIME DEFAULT GETDATE(),
	UPDATED_DATE DATETIME DEFAULT GETDATE()
);

-- Bảng Dim_Reason 
-- Phục vụ: tỉ lệ chuyến bay bị huỷ theo nguyên nhân

CREATE TABLE DIM_REASON (
    Reason_Key INT IDENTITY(1,1) PRIMARY KEY,
	Reason_Code CHAR(1),
	Reason_Description NVARCHAR(255) NOT NULL,
	CREATED_DATE DATETIME DEFAULT GETDATE(),
	UPDATED_DATE DATETIME DEFAULT GETDATE()
);

-- Bảng Dim_Time_Of_Day 
-- Phân tích delay theo thời điểm trong ngày

CREATE TABLE DIM_TIME_OF_DAY (
    Time_Of_Day_Key INT IDENTITY(1,1) PRIMARY KEY,
	Hour INT NOT NULL, -- Giờ trong ngày (0–23), join từ Scheduled_Departure_Hour
	Time_Of_Day_Name VARCHAR(50) NOT NULL, -- Night, Early Morning, Morning, Afternoon, Evening
	CREATED_DATE DATETIME DEFAULT GETDATE(),
	UPDATED_DATE DATETIME DEFAULT GETDATE()
);


-- Bảng Fact_Flight_Performance

CREATE TABLE FACT_FLIGHT (
    Flight INT IDENTITY(1,1) PRIMARY KEY,
    -- FOREIGN KEYS (DIMENSIONS)
    Date_Key INT NOT NULL,
	Airline_Key INT NOT NULL,
	Origin_Airport_Key INT NOT NULL,
	Dest_Airport_Key INT NOT NULL,
	Reason_Key INT,
	Time_Of_Day_Key INT,

	-- DEGENERATE DIMENSIONS
	Flight_Number INT,

	-- MEASURES (FACTS)
	Flight_Count INT NOT NULL DEFAULT 1, -- Luôn = 1, dùng để đếm số chuyến bay
	Dep_Delay_Minutes INT, -- Thời gian trễ lúc khởi hành
	Arr_Delay_Minutes INT, -- Thời gian trễ lúc đến nơi
	--Taxi_Out INT, -- Thời gian lăn bánh ra
	--Taxi_In INT, -- Thời gian lăn bánh vào
	--Air_Time INT, -- Thời gian bay trên không
      
    -- KPI FLAGS (0 / 1)
	Is_Cancelled INT NOT NULL, -- 1: chuyến bị hủy
	Is_Diverted INT NOT NULL, -- 1: chuyển hướng
	Is_OTP INT, -- 1: Arr_Delay <= 15 phút
	Is_Delayed INT, -- 1: Dep_Delay > 15 phút

    -- DELAY BREAKDOWN
	Air_System_Delay INT NOT NULL DEFAULT 0,
	Security_Delay INT NOT NULL DEFAULT 0,
	Airline_Delay INT NOT NULL DEFAULT 0,
	Late_Aircraft_Delay INT NOT NULL DEFAULT 0,
	Weather_Delay INT NOT NULL DEFAULT 0,

	CREATED_DATE DATETIME DEFAULT GETDATE(),
	UPDATED_DATE DATETIME DEFAULT GETDATE(),

	CONSTRAINT FK_Fact_Date FOREIGN KEY (Date_Key) REFERENCES DIM_DATE(Date_Key),
	CONSTRAINT FK_Fact_Airline FOREIGN KEY (Airline_Key) REFERENCES DIM_AIRLINE(Airline_Key),
	CONSTRAINT FK_Fact_OriginAirport FOREIGN KEY (Origin_Airport_Key) REFERENCES DIM_AIRPORT(Airport_Key),
	CONSTRAINT FK_Fact_DestAirport FOREIGN KEY (Dest_Airport_Key) REFERENCES DIM_AIRPORT(Airport_Key),
	CONSTRAINT FK_Fact_Reason FOREIGN KEY (Reason_Key) REFERENCES DIM_REASON(Reason_Key),
	CONSTRAINT FK_Fact_TimeOfDay FOREIGN KEY (Time_Of_Day_Key) REFERENCES DIM_TIME_OF_DAY(Time_Of_Day_Key)
);





USE DDS_DATH;
GO

-- Xóa dữ liệu cũ nếu cần (chỉ dùng khi làm lại)
-- TRUNCATE TABLE DIM_DATE;

DECLARE @StartDate DATE = '2015-01-01';
DECLARE @EndDate   DATE = '2015-12-31';

;WITH Date_CTE AS (
    SELECT @StartDate AS Full_Date
    UNION ALL
    SELECT DATEADD(DAY, 1, Full_Date)
    FROM Date_CTE
    WHERE Full_Date < @EndDate
)
INSERT INTO DIM_DATE (
    Date_Key,
    Full_Date,
    Year,
    Quarter,
    Month,
    Month_Name,
    Day,
    Day_Of_Week,
    Day_Name,
    Is_Weekend,
    Season,
    CREATED_DATE,
    UPDATED_DATE
)
SELECT
    CONVERT(INT, FORMAT(Full_Date, 'yyyyMMdd')) AS Date_Key,
    Full_Date,
    YEAR(Full_Date) AS Year,
    DATEPART(QUARTER, Full_Date) AS Quarter,
    MONTH(Full_Date) AS Month,
    DATENAME(MONTH, Full_Date) AS Month_Name,
    DAY(Full_Date) AS Day,
    DATEPART(WEEKDAY, Full_Date) AS Day_Of_Week,
    DATENAME(WEEKDAY, Full_Date) AS Day_Name,
    CASE 
        WHEN DATEPART(WEEKDAY, Full_Date) IN (1, 7) THEN 1
        ELSE 0
    END AS Is_Weekend,
    CASE 
        WHEN MONTH(Full_Date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(Full_Date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(Full_Date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END AS Season,
    GETDATE(),
    GETDATE()
FROM Date_CTE
OPTION (MAXRECURSION 0);

USE DDS_DATH;
GO

-- Xóa dữ liệu cũ nếu cần
-- TRUNCATE TABLE DIM_TIME_OF_DAY;

DECLARE @Hour INT = 0;

WHILE @Hour <= 23
BEGIN
    INSERT INTO DIM_TIME_OF_DAY (
        Hour,
        Time_Of_Day_Name,
        CREATED_DATE,
        UPDATED_DATE
    )
    VALUES (
        @Hour,
        CASE
            WHEN @Hour BETWEEN 0 AND 4  THEN 'Night'
            WHEN @Hour BETWEEN 5 AND 8  THEN 'Early Morning'
            WHEN @Hour BETWEEN 9 AND 11 THEN 'Morning'
            WHEN @Hour BETWEEN 12 AND 16 THEN 'Afternoon'
            ELSE 'Evening'
        END,
        GETDATE(),
        GETDATE()
    );

    SET @Hour = @Hour + 1;
END;

--INSERT INTO DIM_REASON (Reason_Code, Reason_Description, CREATED_DATE, UPDATED_DATE)
--VALUES ('N', 'Not Cancelled', GETDATE(), GETDATE());


select * from DIM_DATE;

Select * from DIM_AIRLINE;
Select * from DIM_AIRPORT;
Select * from DIM_REASON;
select * from FACT_FLIGHT;