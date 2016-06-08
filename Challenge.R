####VMM 04/09/2015
###Data Incubator Question 1
#### NUMBER OR M
num <- 10000

#### NUMBER OF SIMULATIONS
sim <- 1000

#### Starting data frame values are meaningless testnum=1:sim value=1:sim testnum <- 1:sim value <- 1:sim
test=data.frame(testnum=testnum,value=value)


### FUNCTION TO SUM DICE UNTIL
### SUM IS GREATER THAN OR EQUAL TO "M"
### SAMPLE FOR A NUMBER OF TIMES UP TO "iter"
### PASS BACK THROUGH A DATAFRAME
DiceSum = function(M, iter, dataframe)
{
  i <- 1;
  
  testnum <- numeric();
  value <- numeric();
  
  while(i < iter+1)
  {
    sum <- 0;
    rolls <- 0;
    
    while(M > sum)
    {
      sum = sum + sample(1:6,1,rep=T);
      rolls = rolls + 1;
    }
    
    testnum[i] <- rolls;
    value[i] <- sum;
    
    i = i + 1;
  } 
  
  dataframe$testnum <- testnum;
  dataframe$value <- value;
  
  dataframe
}

test <- DiceSum(num, sim, test)

###CHECK TO ENSURE VALUES MAKE SENSE
#test$testnum
#test$value

### MEAN AND STANDARD DEVIATION OF ROLLS MINUS M mean(test$value - num) sd(test$value - num) ### MEAN AND STANDARD DEVIATION OF ROLLS TO GET TO M
mean(test$testnum)
sd(test$testnum)

# M = 20
#> mean(test$value - num)
#[1] 1.66174
#> sd(test$value - num)
#[1] 1.489987
#> mean(test$testnum)
#[1] 6.19175
#> sd(test$testnum)
#[1] 1.217866

#M = 10000
#> mean(test$value - num)
#[1] 1.643
#> sd(test$value - num)
#[1] 1.435832
#> ### MEAN AND STANDARD DEVIATION OF ROLLS TO GET TO M 
#  > mean(test$testnum) 
#[1] 2857.128 
#> sd(test$testnum) #[1] 25.94295

####VMM 04/09/2015
###Data Incubator Question 2
###http://faculty.washington.edu/ezivot/econ424/Working%20with%20Time%20Series%20Data%20in%20R.pdf

library(chron)
library(lubridate)
library(timeDate)

setwd("~/Documents")
#setwd("C:/Users/n0084531/Desktop")

tripcolClasses = c("factor", "factor", "factor",
                   "factor", "factor", "timeDate", "timeDate",
                   "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric")

farecolClasses = c("factor", "factor", "factor",
                   "timeDate", "factor", "numeric", "numeric",
                   "numeric", "numeric", "numeric", "numeric")

trip <- read.csv(file="trip_data_3.csv",header=TRUE, colClasses=tripcolClasses)
fare <- read.csv(file="trip_fare_3.csv", header=TRUE, colClasses=farecolClasses)

##TRIPS SUMMARY
names(trip)
#summary(trip)

###FARE SUMMARY
names(fare)
#summary(fare)

###What fraction of payments under $5 use a credit card *

###NUMBER OF CREDIT CARD PAYMENTS UNDER $5
length(fare$total_amount[fare$total_amount<5 & fare$payment_type == "CRD"])
### DOUBLE CHECK NUMBER OF PAYMENTS
length(fare$total_amount[fare$payment_type == "CRD"])
### DO THE MATH
length(fare$total_amount[fare$total_amount<5 & fare$payment_type == "CRD"]) / length(fare$total_amount[fare$payment_type == "CRD"])


###What fraction of payments over $50 use a credit card*

###NUMBER OF CREDIT CARD PAYMENTS OVER $50
length(fare$total_amount[fare$total_amount>50 & fare$payment_type == "CRD"])
### NUMBER OF PAYMENTS OVER $50
length(fare$total_amount[fare$total_amount > 50])
### DO THE MATH
length(fare$total_amount[fare$total_amount>50 & fare$payment_type == "CRD"]) / length(fare$total_amount[fare$total_amount > 50])

###MERGE THE DATAFRAMES TO ANSWER THE NEXT QUESTION
# merge two data frames by medallion, hack_license, vendor_id, pickup_datetime
taxi <- merge(fare,trip,by=c("medallion","hack_license", "vendor_id","pickup_datetime"), all=FALSE)

trip[sample(nrow(trip), 3), ]

###What is the mean fare per minute driven?*



###What is the median of the taxi's fare per mile driven?*

###What is the 95 percentile of the taxi's average driving speed in miles per hour?*

###What is the average ratio of the distance between the pickup and dropoff divided by the distance driven?*

###What is the average tip for rides from JFK?*

###What is the median March revenue of a taxi driver?*