#!/bin/bash

set -e
source ./config

gwasoutcome=${1}

mkdir -p ${section_05_dir}
mkdir -p ${section_05_dir}/logs

## Sibling unified regression
echo "Merging results across batches..."

# Extract header from first results file
head -n1 ${section_04_dir}/output.1.${gwasoutcome}_results.txt > ${section_04_dir}/header.${gwasoutcome}.txt

# Remove headers from all files
sed -i '1d' ${section_04_dir}/output.*.${gwasoutcome}_results.txt

# Merge all files
cat ${section_04_dir}/header.${gwasoutcome}.txt ${section_04_dir}/output.*.${gwasoutcome}_results.txt > ${section_05_dir}/combined.sumstats.${gwasoutcome}.txt

echo "All finished!"
