#!/bin/bash

TodayDirectory="${HOME}/BioinfWorkshop2020/Part1_Linux/"

echo "Setting up directories and copying files from previous day into ${TodayDirectory}"

# Setup Commands
mkdir -p ${TodayDirectory}
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part1_Linux/table.txt ${TodayDirectory}
cp /uufs/chpc.utah.edu/common/home/round-group2/BioinfWorkshop2020/Part1_Linux/read*.fastq ${TodayDirectory}

echo "Done."
echo "Current directory is $PWD"

