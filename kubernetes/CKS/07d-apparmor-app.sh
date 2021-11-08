#!/bin/bash

data_directory=/tmp/log/data
mkdir -p ${data_directory}
echo "=> File created at `date`" | tee ${data_directory}/create.log
