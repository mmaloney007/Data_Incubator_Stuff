library("RODBC")
odbcDataSources()

ch <- odbcConnect("database1")
#### What is the mean fare per minute driven?*
df3 <- sqlQuery(ch, paste('select avg((fare_amount) / (trip_time_in_secs/60)) as mean_fare_per_minute from TABLE1'))
transform(df3, mean_fare_per_minute = as.numeric(mean_fare_per_minute))
mean(df3$mean_fare_per_minute, na.rm=TRUE)
####1.412929

### What is the median of the taxi's fare per mile driven?**
df4 <- sqlQuery(ch, paste('select cast(fare_amount /trip_distance as DECIMAL) as fare_per_mile from TABLE1'))
transform(df5, fare_per_mile = as.numeric(fare_per_mile))
median(df4$fare_per_mile, na.rm=TRUE)
###$6.27

###What is the 95 percentile of the taxi's average driving speed in miles per hour?*
df5 <- sqlQuery(ch, paste('select
(trip_distance / (trip_time_in_secs / 3600)) as ave_drive_speed
from TABLE1'))
transform(df5, ave_drive_speed = as.numeric(ave_drive_speed))
quantile(df5$ave_drive_speed, c(.25, .50, .95), na.rm=TRUE) 
###26.58261

### What is the average ratio of the distance between the pickup and dropoff divided by the distance driven?*
df6 <- sqlQuery(ch, paste('SELECT trip_distance, 
   (69 * (DEGREES(ACOS(COS(RADIANS(pickup_latitude)) * COS(RADIANS(dropoff_latitude)) *
             COS(RADIANS(pickup_longitude) - RADIANS(dropoff_longitude)) +
             SIN(RADIANS(pickup_latitude)) * SIN(RADIANS(dropoff_latitude)))))) AS actual_ml
  FROM TABLE1
where
trip_distance <> 0
and
(pickup_latitude <> 0 and dropoff_latitude <> 0 and pickup_longitude <> 0 and dropoff_longitude <> 0 )'))
mean(df6$actual_ml/df6$trip_distance, na.rm=TRUE)
### 0.9713058

### What is the average tip for rides from JFK?*
###Perimeter Road, Jamaica, NY 11430, USA"
### "lat" : 40.6409891,
### "lng" : -73.77432019999999
### using within a 30 mile radius of googles accepted location as it is 880 square miles
df7 <- sqlQuery(ch, paste('select tip_amount, 
   (69 * (DEGREES(ACOS(COS(RADIANS(pickup_latitude)) * COS(RADIANS(40.6409891)) *
             COS(RADIANS(pickup_longitude) - RADIANS(-73.77432019999999)) +
             SIN(RADIANS(pickup_latitude)) * SIN(RADIANS(40.6409891)))))) AS distance_from_jfk
 from TABLE1
 HAVING distance_from_jfk < 30'))
mean(df7$tip_amount, na.rm=TRUE)
### 1.303936

### What is the median March revenue of a taxi driver?*
### DEFINE REVENUE AS TOTAL AMMOUNT
### DEFINE A DRIVER AS DISTINCT HACK LICENSE AND NOT A COMBO OF MEDIALION AS THEY COULD CHANGE CABS (32,991)
### ASSUME DRIVER KEEP ANY FARE STARTED IN MARCH FOR MARCH (THERE ARE SOME THAT END IN APRIL, THIS COULD BE HANDLE WITH EXCLUDING END TIMES)
df8 <- sqlQuery(ch, paste('select hack_license, SUM(total_amount) as revenue
 from TABLE1
group by 1'))
str(df8)
median(df8$revenue, na.rm=TRUE)
### 7221.2
