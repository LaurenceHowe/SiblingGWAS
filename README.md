# SiblingGWAS

Scripts for running GWAS using siblings to estimate Within-Family (WF) and Between-Family (BF) effects of genetic variants on continuous traits. Allows the inclusion of more than two siblings from one family.

<b> INPUT FILES required: </b>
1) Imputed genotype data in PLINK binary format (.bed .bim .fam). <br/>
a) The first two columns of the .fam file must contain the Family ID (FID), common between sibling pairs and distinct between non-sibling pairs, and a unique Individual ID (IID) for each participant. <br/>
b) Siblings are defined as follows: <br/>
c) Genotype data should be on build 37. <br/>
d) Genotype data should be merged into one file across chromosomes. <br/>
e) Chromosomes should be numbered 1-23 in .bim file. <br/>
f) Filtered variants such that INFO > 0.3 & MAF > 0.01. <br/>

2) Covariate file in tab delimited format. <br/>
a) First column should be IID. <br/>
b) Second or third column should contain Age (years), labelled as "Age". <br/>
c) Second or third column should contain Sex, labelled as "Sex". Males should be coded as 1 and females as 0. <br/>

3) Phenotype file in tab delimited format. <br/>
a) First column should be IID. <br/>
b) Rest of columns should contain available phenotypes labelled as follows: "Height" "BMI". <br/>

4) SNP INFO file in tab delimited format. <br/>
a) First column should be SNP id. <br/>
b) Second column should be minor allele frequency. <br/>
c) Third column should be INFO score. <br/>

<b> OUTPUT </b>

Summary statistics file with:
SNP information (CHR, BP, A1, A2, MAF, callrate), betas, standard errors, P-values and variance-covariance matrix coefficients for intercept, WF estimates and BF estimates.

<b> config file </b>

File to be edited with paths to relevant input files. <br/>
Note that only this file should be edited. <br/>

<b> 1.0_setup </b>

The set-up script runs checks to ensure that the input files are in the correct format and checks the installation of R packages.

<b> 2.0_phenotypes </b>

The phenotypes script extracts summary data on available phenotypes.

<b> 3.0_genotypes </b>

The genotypes script extracts summary data on the genotype data.

<i> 1.0_convert_data </i> prepares the genetic data for analysis and extracts relevant information on variants (e.g. MAF).

<i> 2.0_unified_regression </i> runs the regressions in R.

<i> 3.0_merge_results </i> merges the files across chromosomes into a final summary statistics file.


Any queries to Laurence Howe laurence.howe@bristol.ac.uk

Note scripts were adapted from scripts by Gibran Hemani & Sean Lee.
