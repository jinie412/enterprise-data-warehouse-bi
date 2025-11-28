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
    timestamp DATETIME NOT NULL,
    object INT NULL,              
    rows INT NULL,
    note VARCHAR(255) NULL,
    data_flow INT NULL,
    
    
    FOREIGN KEY (event_type) REFERENCES event_type(event_type_key),
    FOREIGN KEY (data_flow) REFERENCES data_flow(data_flow_key)
);