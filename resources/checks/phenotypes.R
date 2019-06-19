errorlist <- list()
warninglist <- list()

library(data.table)
suppressMessages(library(matrixStats))



args <- (commandArgs(TRUE));
phenotypes_file <- as.character(args[1]);
covariates_file <- as.character(args[2]);
