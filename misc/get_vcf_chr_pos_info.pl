#!/software/bin/perl
use strict;


## This script extracts the first 7 columns (CHROM,POS,ID,REF,ALT,QUAL,FILTER)
## of the VCF file and any tags from the INFO field that are specified, eg. DP,HWE,CSQ

## Usage: perl get_vcf_chr_pos_info.pl input.vcf.gz comma-separated-tags
## Example: perl get_vcf_chr_pos_info.pl input.vcf.gz DP,HWE,CSQ > file.out
## Note: It is not possible to search for INDELs with this script, use "grep INDEL" instead.
## Author: Klaudia Walter


##### Input VCF file (INFO field is in column 8) #####

## open VCF file
open(INFILE, "gunzip -c $ARGV[0] |") || die "can't open pipe to $ARGV[0]";

## get comma separated INFO tags
my $infotags = $ARGV[1];
my @tags = split(",", $infotags);

## number of requested tags
my $n = scalar(@tags);
if ($n==0)  {
    print("Error: INFO tags are missing\n");
}

## print header line
print("CHROM","\t","POS","\t","ID","\t","REF","\t","ALT","\t","QUAL","\t","FILTER","\t");
my $header = join("\t", @tags);
print($header, "\n");

## loop through VCF file
while (my $line = <INFILE>)  {
    chomp $line;
    if ($line !~ /^#/)  {
	my @cols = split(" ", $line);
        ## print first 7 columns
	my $chrpos = join("\t", @cols[0..6]);
	print($chrpos, "\t");
	my @info = split(";", $cols[7]);
        ## number of INFO tags in VCF file
        my $m = scalar(@info);
	
	## loop through requested tags
	for (my $i==0; $i<$n; ++$i)  {
            ## loop through INFO tags
	    for (my $j==0; $j<$m; ++$j)  {
		if ($info[$j] =~ /^$tags[$i]=/)  {
		    my @out = split("=", $info[$j]);
		    print($out[1]);
		}
	    }
	    if ($n>1 && $i<($n-1))  {
		print("\t");
	    }
 	}
	print("\n");
    }
}
