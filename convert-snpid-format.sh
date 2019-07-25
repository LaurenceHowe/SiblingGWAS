#Script to convert SNPids (second column of .bim file into necessary format).

#Change the file paths below.

awk '{
if (($5 == "A" || $5 == "T" || $5 == "C" || $5=="G") &&  ($6 == "A" || $6 == "T" || $6 == "C" || $6=="G"))
   print $1, "chr"$1":"$4":SNP", $3, $4, $5, $6;
else
   print $1, "chr"$1":"$4":INDEL", $3, $4, $5, $6;
     }' oldfile.bim > newfile.bim
