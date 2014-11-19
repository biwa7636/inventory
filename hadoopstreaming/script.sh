#!/bin/bash
hdfs dfs -rmr <hdfspath_output>

hadoop jar \
/opt/cloudera/parcels/CDH-5.1.0-1.cdh5.1.0.p0.53/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.3.0-mr1-cdh5.1.0.jar \
-files mapper.py,reducer.R \
-input <hdfspath_input> \
-output <hdfspath_output> \
-mapper mapper.py \
-reducer reducer.R

