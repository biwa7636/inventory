#!/usr/bin/Rscript

library(dplyr)

#options(warn=-1)
#sink("/dev/null")

f <- file("stdin")
open(f, open="r")

# delimiter between key and value
mydelimiter <- rawToChar(as.raw(1))
# delimiter between columns inside either key/value
mydelimiter_col <- rawToChar(as.raw(2))

myfunction <- function(inputarray){

 tryCatch(
   {
    # TURN INTO DATAFRAME
    tmp <- lapply(inputarray, FUN=function(x) strsplit(x, rawToChar(as.raw(2))))
    tmp <- data.frame(matrix(unlist(tmp), ncol=3, byrow=TRUE))
    names(tmp) <- c("date", "qtyavail", "price")
    data <- tmp
    data$date <- as.Date(as.character(data$date), "%Y%m%d")
    data$qtyavail <- as.numeric(as.character(data$qtyavail))
    data$price <- as.numeric(as.character(data$price))

    # REMOVE OUTLIER
    qtyavail_threshold <- 10 * mean(data$qtyavail)
    data <- data %>% filter(qtyavail < qtyavail_threshold)

    # GROUP BY DAY AND GET DIFF
    result <- data %>% group_by(date) %>% summarise(qtyavail_max = max(qtyavail)) %>% arrange(date)
    deltas <- -diff(result$qtyavail_max)
    mysummary <- table(sign(deltas))

    goal_price_min <- min(data$price[data$price>0], na.rm=TRUE)
    goal_avgqty <- mean(result$qtyavail_max)
    goal_sell <- sum(pmax(0, deltas))
    goal_buy <- abs(sum(pmin(0, deltas)))
    goal_days_sell <- max(mysummary["1"], 0)
    goal_days_buy <- max(mysummary["-1"], 0)
    goal_days_static <- max(mysummary["0"], 0)
    return(goal_sell)
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

while( length(line<-readLines(f, n=1)) > 0){
    fields <- unlist(strsplit(line, split=mydelimiter))
    mykey_new <- fields[1]
    myvalue_new <- fields[2]

    if (identical(mykey_new, mykey_current)) {
        # Same Key: append new value to existing value array
        myvalue_array <- c(myvalue_array, myvalue_new)
    } else {
        # Different Key
        # (1): process existing values
        result <- myfunction(myvalue_array)
        cat(mykey_current); cat(mydelimiter)
        cat(result); cat('\n')
        # (2): reset key, value
        mykey_current <- mykey_new
        myvalue_array <- array(myvalue_new)
    }
}

# LAST LINE
result <- myfunction(myvalue_array)
cat(mykey_current); cat(mydelimiter)
cat(result); cat('\n')


