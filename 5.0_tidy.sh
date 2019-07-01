#!/bin/bash

set -e
source ./config

mkdir -p ${section_04_dir}/merged

## Sibling unified regression
echo "Merging results across batches..."

# Extract header from first results file
head -n1 ${section_04_dir}/output.1_results.txt > ${section_04_dir}/merged/header.txt

# Remove headers from all files
sed -i '1d' output/split*_sibs_WFunified_results.txt

# Merge all files
cat ${section_04_dir}/merged/header.txt ${section_04_dir}/output* > ${section_04_dir}/merged/combined.sumstats.txt

echo "All finished!"
