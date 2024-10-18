CREATE DATABASE NewDatabase;
USE NewDatabase;
CREATE TABLE Region ( 
    RegionID int PRIMARY KEY NOT NULL, 
    RegionDescription nchar(50) NOT NULL );
ALTER TABLE Region ADD Help nchar(16);
CREATE TABLE Territories (
	TerritoryID nvarchar(20) PRIMARY KEY NOT NULL,
	TerritoryDescriprion nchar(50) NOT NULL,
	RegionID int FOREIGN KEY REFERENCES Region(RegionID) NOT NULL);
