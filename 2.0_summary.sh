#!/bin/bash

set -e
source ./config

mkdir -p ${section_02_dir}
mkdir -p ${section_02_dir}/logs

exec &> >(tee ${section_02_logfile})

Rscript resources/summary/summary.R \
		${phenotypes} \
		${covariates} \
		${phenotype_list} \
		${covariate_list} \
		${summary_file}
		 
