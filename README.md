# SiblingGWAS

Scripts for running GWAS using siblings to estimate Within-Family (WF) and Between-Family (BF) effects of genetic variants on continuous traits. Allows the inclusion of more than two siblings from one family.

<b> INPUT FILES required: </b>
1) Imputed genotype data in PLINK binary format (.bed .bim .fam). The first two columns of the .fam file must contain the Family ID (FID), which should be the same for siblings and distinct for non-siblings, and a unique Indiviudal ID (IID) for each participant. 

Genotype data should be on build 37, merged into one file across chromosomes and with chromosomes numbered 1-23 in .bim file.

2) Phenotype file: format (IID, Phenotype).
3) Covariate file: format (IID, Age, Sex).
4) INFO file.

<b> config file </b>

File to be edited with paths to relevant input files.
Note that only this file should be edited.

<b> 1.0_setup </b>

The set-up script runs checks to ensure that the input files are in the correct format and checks the installation of R packages.

<b> 2.0_siblings </b>

<i> 1.0_convert_data </i> prepares the genetic data for analysis and extracts relevant information on variants (e.g. MAF).

<i> 2.0_unified_regression </i> runs the regressions in R.

<i> 3.0_merge_results </i> merges the files across chromosomes into a final summary statistics file.

<b> OUTPUT </b>

Summary statistics file with:
SNP information (CHR, BP, A1, A2, MAF, callrate), betas, standard errors, P-values and variance-covariance matrix coefficients for intercept, WF estimates and BF estimates.



Any queries to Laurence Howe laurence.howe@bristol.ac.uk

Note scripts were adapted from scripts by Gibran Hemani & Sean Lee.
