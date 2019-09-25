# #!/bin/bash

task(){
	echo "$1"
	bash 4.0_unified_regression.sh $1 BMI
}

n_jobs=4
n_process=2

(
for j in $(seq 1 $n_jobs); do
   ((i=i%n_process)); ((i++==0)) && wait
   task "$j" &
done
)

