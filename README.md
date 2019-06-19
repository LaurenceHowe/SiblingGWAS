# SiblingGWAS

Scripts for running GWAS using siblings to estimate Within-Family (WF) and Between-Family (BF) effects of genetic variants on continuous traits. Allows the inclusion of more than two siblings from one family.

INPUT FILES required:
1) List of siblings and residualized phenotype in a tab-separated text file with 3 columns (FID, IID, Phenotype)
2) Imputed genotype data for siblings, split across chromosomes, in PLINK binary format (.bed .bim .fam)

MASTER_SCRIPT_nopaths calls the relevant subscripts for running the analysis.
This script must be edited for file path names.

<i> 1.0_convert_data </i> prepares the genetic data for analysis and extracts relevant information on variants (e.g. MAF).

<i> 2.0_unified_regression </i> runs the regressions in R.

<i> 3.0_merge_results </i> merges the files across chromosomes into a final summary statistics file.

OUTPUT:

Summary statistics file with:
SNP information (CHR, BP, A1, A2, MAF, callrate), betas, standard errors, P-values and variance-covariance matrix coefficients for intercept, WF estimates and BF estimates.



Any queries to Laurence Howe laurence.howe@bristol.ac.uk

Note scripts were adapted from original scripts by Sean Lee.
