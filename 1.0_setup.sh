#!/bin/bash

set -e
source ./config
exec &> >(tee ${section_01_logfile})

containsElement () {
	local e
	for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
	echo "There is no method for ${1}."
	echo "Please run:"
	echo "./01-check_data [arg]"
	echo "where arg is an optional argument that can be one of:"
	printf '%s\n' ${@:2}
	return 1
}

arg="all"
declare -a sections=('all' 'config' 'requirements' 'genetics' 'covariates' 'phenotypes')


if [ -n "${1}" ]; then
	arg="${1}"
	containsElement ${1} ${sections[@]}
fi

section_message () {
	echo "-----------------------------------------------"
	echo ""
	echo "$1 section"
	echo ""
	echo "to run this part on its own type:"
	echo "$ ./01-check_data.sh $1"
	echo ""
	echo "-----------------------------------------------"
	echo ""
	echo ""
}

#Check study name

if [ "$arg" = "config" ] || [ "$arg" = "all" ]
then
	section_message "config"
	if ! [[ "$study_name" =~ [^a-zA-Z0-9_\ ] ]] && ! [ "$study_name" = "" ]
	then
		echo "The study name '${study_name}' will be used for this analysis. Change this in the config file if necessary."
		echo ""
	else
		echo "The study name '${study_name}' is invalid. Please use only alphanumeric or underscore characters, with no spaces or special characters etc."
		exit
	fi
fi

#Check R version and packages

if [ "$arg" = "requirements" ] || [ "$arg" = "all" ]
then
	section_message "requirements"
    Rscript resources/checks/packages.R
fi

#Check genotype file

if [ "$arg" = "genetics" ] || [ "$arg" = "all" ]
then
	section_message "covariates"
	Rscript resources/checks/genetics.R \
		${bfile_raw}.bim \
		${bfile_raw}.fam \
		${quality_scores} \
		${controlsnps_file} 
fi

#Check covariate file

if [ "$arg" = "covariates" ] || [ "$arg" = "all" ]
then
	section_message "covariates"
	Rscript resources/checks/covariates.R \
		${covariates} \
		${bfile_raw}.fam \
		${phenotypes} 
fi

#Check phenotype file

if [ "$arg" = "phenotypes" ] || [ "$arg" = "all" ]
then
	section_message "phenotypes"
	Rscript resources/checks/phenotypes.R \
		${phenotypes} \
		${covariates} \
		${bfile_raw}.fam \
		${phenotype_list}
fi

#Finish 

if [ "$arg" = "all" ]
then
        echo ""
        echo ""
        echo "You successfully performed all data checks!"
fi

