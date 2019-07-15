# SiblingGWAS

Scripts for running GWAS using siblings to estimate Within-Family (WF) and Between-Family (BF) effects of genetic variants on continuous traits. Allows the inclusion of more than two siblings from one family.
<br>
<br>
<b> Basic Requirements </b>

1) <b> Siblings</b>. Consider all families with one or more pairs of genotyped dizygotic siblings. From these families, include all siblings. For example, in a family with a pair of monozygotic twins and an additional sibling, include both MZ twins and the sibling. The inclusion of both MZ twins should (very) modestly improve power by accounting for variation in the phenotypic outcome.  
If siblings have not been previously identified in the dataset, we suggest using KING (http://people.virginia.edu/~wc9c/KING/manual.html) to infer siblings.
2) <b> Imputed genotype data</b>. The analysis scripts use best guess genotype data in PLINK binary format. We have provided scripts to convert different file formats (vcf, bgen) to PLINK binary best guess format.
3) <b> Phenotypes</b>. Phenotype data for siblings on outcomes of interest which include height and body mass index.
<br>
<b> INPUT FILES: </b>

<b> Imputed genotype data:</b> <br/>
  
a) PLINK binary format (.bed .bim .fam) with one file containing all 23 chromosomes. <br/>
  
b) The first two columns of the .fam file must contain the Family ID (FID), common between sibling pairs and distinct between non-sibling pairs, and a unique Individual ID (IID) for each participant. <br/>
<br/>
For example, the following IIDs are not unique: <br/>
Family1 Sibling1 <br/>
Family1 Sibling2 <br/>
Family2 Sibling1 <br/>
Family2 Sibling2 <br/>
<br/>
c) The SNP IDs in the second column of the .bim file should be in CHR:BP format with markers labelled as SNP or INDEL.  

For example:  

1       chr1:10177:INDEL        0       10177   AC      A  

1       chr1:10352:INDEL        0       10352   TA      T  

1       chr1:11008:SNP          0       11008   G       C
  
  
d) Genotype data should be on build 37.  

f) Chromosomes should be numbered 1-23 in .bim file.  

g) Filtered variants such that INFO > 0.3 & MAF > 0.01.  


<b>Covariate file in tab delimited format. </b> <br/>
a) First column should be FID/IID. <br/>
b) Third or fourth column should contain Age (years), labelled as "Age". <br/>
c) Third or fourth column should contain Sex, labelled as "Sex". Males should be coded as 1 and females as 0. <br/>

<b>Phenotype file in tab delimited format. </b> <br/>
a) First two columns should be FID/IID. <br/>
b) Rest of columns should contain available phenotypes labelled as follows: "Height" "BMI". <br/>

<b> SNP INFO file in tab delimited format. </b> <br/>
a) First column should be SNP id. <br/>
b) Second column should be minor allele frequency. <br/>
c) Third column should be INFO score. <br/>

<b> OUTPUT FILE: </b>

Summary statistics file with: <br/>
SNP information (CHR, BP, A1, A2, MAF, callrate), betas, standard errors, P-values and variance-covariance matrix coefficients for intercept, WF estimates and BF estimates.

<b> SCRIPTS: </b>  

<b> config file </b>

File to be edited with paths to relevant input files. <br/>
Note that only this file should be edited. <br/>

<b> 1.0_setup </b>

The set-up script runs checks to ensure that the input files are in the correct format and checks the installation of R packages.

<b> 2.0_summary </b>

This script extracts summary data on available phenotypes.

<b> 3.0_partitions </b>

This script partitions the genetic data into smaller lists of SNPs to be run in batches.

<b> 4.0_unified_regression </b> 

This script runs the regressions in R.

<b> 5.0_tidy </b> 

This script compiles the output into a final summary statistics file.

<br>
<br>
Any queries to Laurence Howe laurence.howe@bristol.ac.uk

Note scripts were adapted from scripts by GoDMC (Gibran Hemani) and the SSGAC (Sean Lee). See the Wiki for more information!
