#!/usr/bin/Rscript
library(dplyr)
library(outliers)
library(zoo)
library(forecast)
library(tsoutliers)

f <- file("stdin")
open(f, open="r")

mydelimiter_a <- rawToChar(as.raw(1))
mydelimiter <- '\t'

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
        data.backup <- data %>% group_by(date) %>% summarise(qtyavail_max = max(qtyavail)) %>% arrange(date)
        
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

        # (4) TSOUTLIERS
        # Not Working Yet
        tryCatch(
            {
                data <- data.backup
                data.ts <- zoo(data$qtyavail_max)
                data.ts.model <- auto.arima(data.ts)
                pars <- coefs2poly(data.ts.model)
                #outliers <- locate.outliers(data.ts.model$residuals, pars)
                resid <- residuals(data.ts.model)
                pars <- coefs2poly(data.ts.model)
                print("residuals")
                print(as.character(resid))
                print("pars")
                print(as.character(pars))
                outliers <- locate.outliers(resid, pars)
                print(as.character(outliers))
                data <- data[-c(subset(outliers, type == 'AO')$ind), ]
                deltas <- -diff(data$qtyavail_max)
                sell.tsoutlier <- sum(pmax(0, deltas), na.rm=TRUE)
                buy.tsoutlier <- sum(pmin(0, deltas), na.rm=TRUE)
                output <- gsub('NA', '-1', output)
            },
            error=function(e){
                print(head(data))
                print(as.character(e))
            }
        )
        
        ############################
        # GOALS FOR EACH PRODUCT   #
        ############################
        #goal_price_min <- min(data$price[data$price>0], na.rm=TRUE)
        #goal_avgqty <- mean(result$qtyavail_max)
        #goal_sell <- sum(pmax(0, deltas))
        #goal_buy <- abs(sum(pmin(0, deltas)))
        #goal_days_sell <- max(mysummary["1"], 0)
        #goal_days_buy <- max(mysummary["-1"], 0)
        #goal_days_static <- max(mysummary["0"], 0)  
        #output<-paste(goal_price_min, goal_avgqty, goal_sell, goal_buy, goal_days_sell, goal_days_buy, goal_days_static, sep=mydelimiter_a)
        #output<-gsub('NA', '-1', output)
        output <- paste(sell.raw, sell.median, sell.outlier, sell.tsoutlier, buy.raw, buy.median, buy.outlier, buy.tsoutlier, sep=mydelimiter_a)
        return(output)
    },

    error=function(e){
      msg <- as.character(e)
      msg <- gsub('\n', '', msg)
      return(msg)
    }
  )
}

# FIRST LINE
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
                cat(mykey_current);cat(mydelimiter_a);cat(result);cat('\n')
                # (2): reset key, value
                mykey_current <- mykey_new
                myvalue_array <- array(myvalue_new)
            }
        },
        error=function(e){
            msg <- as.character(e)
            msg <- gsub('\n', '', msg)
            cat(msg);cat('\n')
        }
    )
}

# LAST LINE
result <- myfunction(myvalue_array)
cat(mykey_current);cat(mydelimiter_a);cat(result);cat('\n')


