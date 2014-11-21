#!/bin/bash
HDFS_INPUT="/tmp/myinput"
HDFS_OUTPUT="/tmp/myoutput"
FILE_MAPPER="mapper.python"
FILE_REDUCER="reducer.R"
STREAMING_JAR="/opt/cloudera/parcels/CDH-5.1.0-1.cdh5.1.0.p0.53/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.3.0-mr1-cdh5.1.1.jar"

# REMOVE PREVIOUS OUTPUT 
hdfs dfs -rmr $HDFS_OUTPUT

# RUN HADOOP STREAMING JOB
hadoop jar $STREAMING_JAR \
-files $FILE_MAPPER,$FILE_REDUCER \
-input $HDFS_INPUT \
-output $HDFS_OUTPUT \
-mapper $FILE_MAPPER \
-reducer $FILE_REDUCER

# MERGE THE OUTPUT TO LOCAL
hdfs dfs -getmerge $HDFS_OUTPUT result
