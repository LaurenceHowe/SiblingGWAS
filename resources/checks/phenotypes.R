errorlist <- list()

warninglist <- list()





library(data.table)

suppressMessages(library(matrixStats))



args <- (commandArgs(TRUE));

phenotypes_file <- as.character(args[1]);

meth_ids_file <- as.character(args[2]);

covariates_file <- as.character(args[3]);

cohort_descriptives_file <- as.character(args[4])

ewas_phenotype_list_file <- as.character(args[5])
