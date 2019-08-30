#!/bin/bash

# This creates a kin0 file of all 2nd degree individuals, along with rplot (y=kinship, x=IBS0).

# The genotyped files should not be pruned

king=/home/ubuntu/tools/king
genotyped=/home/ubuntu/genotypes/genotyped.bed
out=/home/ubuntu/genotypes

# Define all 2nd degree individuals

$king -b $genotyped \
	--related \
        --degree 2 \
	--prefix $out/hunt \
	--rplot \
	--cpus 32 \
       	|& tee $out/hunt.txt

