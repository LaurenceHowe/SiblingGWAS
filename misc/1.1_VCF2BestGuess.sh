#!/bin/bash
plink=plink1.9

# Convert the VCF to PLINK in parrallel and set the file name to 1:23

# CHR1:22

parallel --link plink1.9 --vcf CHR{1}.HRC_WGS.vcf.gz --double-id --make-bed --out data_chr{2}_filtered --noweb ::: {01..22} ::: {1..22} 

#CHR_X
$plink --vcf CHR_X.HRC.vcf.gz --double-id --make-bed --out data_chr23_filtered --noweb &&

wait

for i in {1..23}
do

# Rename the SNP IDs if necessary to avoid possible duplicates
    
cp data_chr${i}_filtered.bim data_chr${i}_filtered.bim.orig
awk '{
       if (($5 == "A" || $5 == "T" || $5 == "C" || $5=="G") &&  ($6 == "A" || $6 == "T" || $6 == "C" || $6=="G")) 
            print $1, "chr"$1":"$4":SNP", $3, $4, $5, $6;
   else 
        print $1, "chr"$1":"$4":INDEL", $3, $4, $5, $6;
   }' data_chr${i}_filtered.bim.orig > data_chr${i}_filtered.bim
  

# Keep SNPs with MAF>0.01 or info>0.8
   
$plink --bfile data_chr${i}_filtered --make-bed --out data_chr${i}_filtered --extract data_chr${i}.keep
   
   # For simplicity remove any duplicates

cp data_chr${i}_filtered.bim data_chr${i}_filtered.bim.orig2
   awk '{
       if (++dup[$2] > 1) { 
           print $1, $2".duplicate."dup[$2], $3, $4, $5, $6 
       } else { 
           print $0 }
   }' data_chr${i}_filtered.bim.orig2 > data_chr${i}_filtered.bim
grep "duplicate" data_chr${i}_filtered.bim | awk '{ print $2 }' > duplicates.chr${i}.txt
    
$plink --bfile data_chr${i}_filtered --exclude duplicates.chr${i}.txt --make-bed --out data_chr${i}_filtered


# Remove duplicates from maf/info file

cp data_chr${i}.info data_chr${i}.info.orig
awk '{
       if (++dup[$1] > 1) {
           print $1".duplicate."dup[$1], $2, $3
       } else {
           print $0 }
    }' data_chr${i}.info.orig > data_chr${i}.info

    fgrep -v -w -f duplicates.chr${i}.txt <data_chr${i}.info >chr${i}_filtered.info
done

# Merge them into one dataset

for i in {2..23}
do 
    echo "data_chr${i}_filtered"
done > mergefile.txt

$plink --bfile data_chr1_filtered --merge-list mergefile.txt --make-bed --out data_filtered

# Combine info files into a single file

head -n1 chr1_filtered.info > data_filtered.info

for i in {1..23}
do
    awk ' NR>1 {print $0}' < chr${i}_filtered.info |cat >> data_filtered.info
done
