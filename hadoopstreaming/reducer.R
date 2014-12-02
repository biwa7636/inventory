#!/usr/bin/Rscript
library(dplyr)
library(outliers)
library(zoo)
#library(forecast)
#library(tsoutliers)
f <- file("stdin")
open(f, open="r")
mydelimiter_a <<- rawToChar(as.raw(1))
mydelimiter <<- '\t'
myrecords_limit <<- 30
 
myfunction <- function(inputarray){
 tryCatch(
    {
        tmp <- lapply(inputarray, FUN=function(x) strsplit(x, mydelimiter_a))
        tmp <- data.frame(matrix(unlist(tmp), ncol=3, byrow=TRUE))
        names(tmp) <- c("date", "qtyavail", "price")
        data <- tmp
        data$date <- as.Date(as.character(data$date), "%Y%m%d")
        data$qtyavail <- as.numeric(as.character(data$qtyavail))
        data$price <- as.numeric(as.character(data$price))
        data.raw <- data
        data.backup <- data %>% group_by(date) %>% summarise(qtyavail_max = max(qtyavail, na.rm=TRUE)) %>% arrange(date)
        if(nrow(data.backup) < 30){return("ERROR_NOT_ENOUGH_RECORDS")}
        #counts <- table(data$price)
        #price <- cat(paste(counts, names(counts), sep="|"), sep=',')
        if(nrow(data.backup)==0){return("ERROR")}
        ###########################
        # REMOVE OUTLIERS         #
        ###########################
        # (1) RAW
        data <- data.backup
        deltas <- -diff(data$qtyavail_max)
        sell.raw <- sum(pmax(0, deltas), na.rm=TRUE)
        buy.raw <- sum(pmin(0, deltas), na.rm=TRUE)
        # (2) MEDIAN
        data <- data.backup
        qtyavail_threshold <- 1000 + 10 * mean(data$qtyavail_max)
        data <- data %>% filter(qtyavail_max < qtyavail_threshold)
        deltas <- -diff(data$qtyavail_max)
        sell.median <- sum(pmax(0, deltas), na.rm=TRUE)
        buy.median <- sum(pmin(0, deltas), na.rm=TRUE)
        # (3) OUTLIERS
        data <- data.backup
        data$qtyavail_max <- rm.outlier(data$qtyavail_max, fill=TRUE, median=TRUE)
        deltas <- -diff(data$qtyavail_max)
        sell.outlier <- sum(pmax(0, deltas), na.rm=TRUE)
        buy.outlier <- sum(pmin(0, deltas), na.rm=TRUE)
        # (4) STANDARD DEVIATION
        #transactions <- deltas[deltas > 0]
        #mysd <- sd(transactions)
        #mymean <- mean(transactions)
        goal_raw_records <- nrow(data)
        goal_aggr_records <- nrow(data.backup)
        goal_qty_unique <- length(unique(data.backup$qtyavail_max))
        goal_qty_mean <- mean(data.backup$qtyavail_max)
        goal_qty_sd <- sd(data.backup$qtyavail_max)
        deltas <- -diff(data.backup$qtyavail_max)
        deltas <- deltas[deltas >= 0]
        goal_dif_unique <- length(unique(deltas))
        goal_dif_mean <- mean(deltas, na.rm=TRUE)
        goal_dif_sd <- sd(deltas, na.rm=TRUE)
        # price might be -1 all the time
        goal_price_min <- min(data.raw$price[data.raw$price > 0], na.rm=TRUE)
        goal_price_min <- min(-1, goal_price_min)
        output <- paste(
            goal_raw_records,
            goal_aggr_records,
            goal_qty_unique,
            goal_qty_mean,
            goal_qty_sd,
            goal_dif_unique,
            goal_dif_mean,
            goal_dif_sd,
            goal_price_min,
            sell.raw, buy.raw,
            sell.median, buy.median,
            sell.outlier, buy.outlier,
            sep=mydelimiter_a
            )
        return(output)
    },
    error=function(e){
      msg <- as.character(e)
      msg <- gsub('\n', '', msg)
      msg <- paste0('FUNCTION_ERROR', msg)
      return(msg)
    }
  )
}
##################################################################
# This is the overhead part of hadoop streaming
# sorted output from the mappers will be read from stdin by reducer
##################################################################
# FIRST LINE
sink('/dev/null')
firstline <- readLines(f, n=1)
fields <- unlist(strsplit(firstline, split=mydelimiter))
mykey_current <- fields[1]
myvalue_array <- array(fields[2])
while(length(line<-readLines(f, n=1)) > 0){
    tryCatch(
        {
            fields <- unlist(strsplit(line, split=mydelimiter))
            mykey_new <- fields[1]
            myvalue_new <- fields[2]
            if ( mykey_new == mykey_current) {
                # Same Key: append new value to existing value array
                myvalue_array <- c(myvalue_array, myvalue_new)
            } else {
                # Different Key
                # (1): process existing values
                result <- myfunction(myvalue_array)
                sink();cat(mykey_current);cat(mydelimiter_a);cat(result);cat('\n');sink('/dev/null');
                # (2): reset key, value
                mykey_current <- mykey_new
                myvalue_array <- array(myvalue_new)
            }
        },
        error=function(e){}
    )
}
# LAST LINE
result <- myfunction(myvalue_array)
sink();cat(mykey_current);cat(mydelimiter_a);cat(result);cat('\n');sink('/dev/null');
