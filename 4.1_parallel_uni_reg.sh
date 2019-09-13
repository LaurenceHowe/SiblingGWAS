#!/bin/bash

# This script runs 4.0_unified_regression.sh in a for loop for all batches and traits

# Number of batches
n_batches=`ls ~/SiblingGWAS/results/03 | grep 'extract' | wc -l`

# Name of trait
trait=BMI

# Loop through batches

parallel -j30 ~/SiblingGWAS/4.0_unified_regression.sh {1} $trait ::: $(seq 0 $n_batches)

