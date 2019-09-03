#!/bin/bash

# This script check that the .fam files have the same IIDs and that they are in the correct order before replacing the file with the one that included FID

prefix=/home/ubuntu/genotypes


for i in {1..23}
 do
        DIFF=$(diff <(cut -f2 -d ' ' $prefix/update.fam) <(cut -f2 -d ' ' $prefix/data_chr${i}_filtered.fam))

        if [ "$DIFF" == "" ]
        then

        cp $prefix/update.fam $prefix/data_chr${i}_filtered.fam

        else

        echo "The $prefix/data_chr${i}_filtered.fam does not match"

        fi

 done
