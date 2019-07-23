#!/bin/bash

set -e
source ./config

mkdir -p ${section_01_dir}
mkdir -p ${section_01_dir}/logs

exec &> >(tee ${section_01_logfile})

Rscript resources/summary/summary.R \
		${phenotypes} \
		${covariates} \
		${phenotype_list} 
		 
