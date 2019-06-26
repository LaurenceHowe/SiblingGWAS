#!/bin/bash

set -e
source ./config

mkdir -p ${section_03_dir}
mkdir -p ${section_03_dir}/logs

exec &> >(tee ${section_03_logfile})

echo "Partitioning genotype file"

#Partition size
size=${chunks_snp_number}

#Partition genotype file into chunks of partition size SNPs
split -l$size -d ${bfile_raw}.bim ${section_03_dir}/extract

#Number of SNPs in .bim file
snpnumber=$(wc -l < ${bfile_raw}.bim)

#Rounding for truncation and count number of files

round=$(echo "$((snpnumber+$size-1))")
partitions=$(echo "$((round/$size))")

echo $snpnumber
echo $partitions
