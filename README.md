# SiblingGWAS

Scripts for running GWAS using siblings to estimate Within-Family (WF) and Between-Family (BF) effects of genetic variants on continuous traits. Allows the inclusion of more than two siblings from one family.
<br>
<br>

<b> Basic Requirements </b>

1) <b> Siblings</b>. The analysis pipeline requires data on siblings. We suggest including all siblings from families with one or more pairs of genotyped dizygotic siblings. For example, in a family with a pair of monozygotic twins and an additional sibling, include both MZ twins and the sibling. The inclusion of both MZ twins should (very) modestly improve power by accounting for variation in the phenotypic outcome.
If siblings have not been previously identified in the dataset, we suggest using KING (http://people.virginia.edu/~wc9c/KING/manual.html) to infer siblings.
2) <b> Imputed genotype data</b>. The analysis scripts use best guess genotype data in PLINK binary format. We have provided scripts to convert different file formats (e.g. vcf, bgen) to PLINK binary best guess format satisfying pipeline input requirements. 
3) <b> Phenotypes</b>. Phenotype data for siblings on outcomes of interest (e.g. height and body mass index).
<br>

For more details on the prerequisites and inputs required for the pipeline, please consult the wiki <br>
https://github.com/LaurenceHowe/SiblingGWAS/wiki/
<br>

<b> Downloading and running the pipeline </b>

Navigate to the directory where you want to download the repository. The repository can then be downloaded using git: <br>
> git clone https://github.com/LaurenceHowe/SiblingGWAS/ <br>
<br>
Once the repository is downloaded, run the following command to check that files have downloaded properly: <br>

> head ./SiblingGWAS/resources/parameters <br>

<br>


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

Note scripts were adapted from scripts by GoDMC (Gibran Hemani et al) and the SSGAC (Sean Lee/Patrik Turley et al). See the Wiki for more information!
