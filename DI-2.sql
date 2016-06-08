CREATE TABLE fare (
  medallion VARCHAR(255) NOT NULL ,
  hack_license VARCHAR(255) NOT NULL,
   vendor_id char(3) NOT NULL,
  pickup_datetime datetime NOT NULL,
  payment_type char(3) NOT NULL,
  fare_amount decimal(10,2) NOT NULL,
  surcharge decimal(10,2) NOT NULL,
  mta_tax decimal(10,2) NOT NULL,
  tip_amount decimal(10,2) NOT NULL,
  tolls_amount decimal(10,2) NOT NULL,
  total_amount decimal(10,2) NOT NULL,
  PRIMARY KEY (medallion, hack_license, vendor_id, pickup_datetime)
);

LOAD DATA LOCAL INFILE '/Users/maloney/Documents/trip_fare_3.csv' 
INTO TABLE fare 
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE trip_data (
  medallion VARCHAR(255) NOT NULL ,
  hack_license VARCHAR(255) NOT NULL,
  vendor_id varchar(3) NOT NULL,
  rate_code varchar(3) NOT NULL,
  store_and_fwd_flag varchar(3) NOT NULL,
  pickup_datetime datetime NOT NULL,
  dropoff_datetime datetime NOT NULL,
  passenger_count int NOT NULL,
  trip_time_in_secs float NOT NULL,
  trip_distance float NOT NULL,
  pickup_longitude float NOT NULL,
  pickup_latitude float NOT NULL,
  dropoff_longitude float NOT NULL,
  dropoff_latitude float NOT NULL,
  PRIMARY KEY (medallion, hack_license, vendor_id, pickup_datetime)
);

LOAD DATA LOCAL INFILE '/Users/maloney/Documents/trip_data_3.csv' 
INTO TABLE trip_data 
FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ###What fraction of payments under $5 use a credit card *

-- TABLE DECLARATION ##################################################
CREATE TEMPORARY TABLE TABLEQ1 (NUMERATOR INT, DENOMINATOR INT, RATIO float) ENGINE=MEMORY;
-- #####################################################################

-- WHAT GETS INSERTED INTO TABLE 1
INSERT INTO TABLEQ1
SELECT
A.NUM, 
A.DENOM,
(convert(A.NUM,DECIMAL(20,10))/convert(A.DENOM,DECIMAL(20,10))) as ratio
FROM
(
-- COLUMN SELECTION. TWO NUMBERS WILL REPRESENT A NUM AND A DENOM
SELECT 
    (select count(*) from fare
		where 
		payment_type = "CRD"
			and 
		total_amount < 5)
        AS NUM,
    (select count(*) from fare
		where 
		total_amount < 5)
        AS DENOM
)A;

-- select cast(NUMERATOR as FLOAT) from TABLE1;

SELECT NUMERATOR, DENOMINATOR, RATIO
FROM TABLEQ1;

DROP TABLE TABLEQ1;

-- ###What fraction of payments over $50 use a credit card*

-- TABLE DECLARATION ##################################################
CREATE TEMPORARY TABLE TABLEQ2 (NUMERATOR INT, DENOMINATOR INT, RATIO float) ENGINE=MEMORY;
-- #####################################################################

-- WHAT GETS INSERTED INTO TABLE 1
INSERT INTO TABLEQ2
SELECT
A.NUM, 
A.DENOM,
(convert(A.NUM,DECIMAL(20,10))/convert(A.DENOM,DECIMAL(20,10))) as ratio
FROM
(
-- COLUMN SELECTION. TWO NUMBERS WILL REPRESENT A NUM AND A DENOM
SELECT 
    (select count(*) from fare
		where 
		payment_type = "CRD"
			and 
		total_amount > 50)
        AS NUM,
    (select count(*) from fare
		where 
		total_amount > 50)
        AS DENOM
)A;

-- select cast(NUMERATOR as FLOAT) from TABLE1;

SELECT NUMERATOR, DENOMINATOR, RATIO
FROM TABLEQ2;

DROP TABLE TABLEQ2;

-- CREATE A MERGED TABLE TO ANSWER THE OTHER QUESTIONS

-- TABLE DECLARATION ##################################################
CREATE TABLE TABLE1 
(  medallion VARCHAR(255) NOT NULL ,
  hack_license VARCHAR(255) NOT NULL,
  vendor_id varchar(3) NOT NULL,
  rate_code varchar(3) NOT NULL,
  store_and_fwd_flag varchar(3) NOT NULL,
  pickup_datetime datetime NOT NULL,
  dropoff_datetime datetime NOT NULL,
  passenger_count int NOT NULL,
  trip_time_in_secs float NOT NULL,
  trip_distance float NOT NULL,
  pickup_longitude float NOT NULL,
  pickup_latitude float NOT NULL,
  dropoff_longitude float NOT NULL,
  dropoff_latitude float NOT NULL,
  payment_type char(3) NOT NULL,
  fare_amount decimal(10,2) NOT NULL,
  surcharge decimal(10,2) NOT NULL,
  mta_tax decimal(10,2) NOT NULL,
  tip_amount decimal(10,2) NOT NULL,
  tolls_amount decimal(10,2) NOT NULL,
  total_amount decimal(10,2) NOT NULL,
  PRIMARY KEY (medallion, hack_license, vendor_id, pickup_datetime)
);
-- #####################################################################

-- WHAT GETS INSERTED INTO TABLE 1
INSERT INTO TABLE1
SELECT
	trip_data.medallion,
	trip_data.hack_license,
	trip_data.vendor_id,
	trip_data.rate_code,
	trip_data.store_and_fwd_flag,
	trip_data.pickup_datetime,
	trip_data.dropoff_datetime,
	trip_data.passenger_count,
	trip_data.trip_time_in_secs,
	trip_data.trip_distance,
	trip_data.pickup_longitude,
	trip_data.pickup_latitude,
	trip_data.dropoff_longitude,
	trip_data.dropoff_latitude,
	fare.payment_type,
	fare.fare_amount,
	fare.surcharge,
	fare.mta_tax,
	fare.tip_amount,
	fare.tolls_amount,
	fare.total_amount
FROM
	trip_data trip_data,
    fare fare
    where
    trip_data.medallion = fare.medallion
    and
	trip_data.hack_license = fare.hack_license
    and
    trip_data.vendor_id = fare.vendor_id
    and
    trip_data.pickup_datetime = fare.pickup_datetime;
