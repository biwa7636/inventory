#!/usr/bin/Rscript
f <- file("stdin")
open(f, open="r")
mydelimiter <- rawToChar(as.raw(1))

myfunction <- function(inputarray){
    # inputarray is an array of all the values in string format
    result <- length(inputarray) 
    return(result)
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




