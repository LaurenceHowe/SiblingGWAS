#!/bin/bash

# This script runs 4.0_unified_regression.sh in parallel for all batches and traits

# Number of batches

#n_batches=`ls ~/SiblingGWAS/results/03 | grep 'extract' | wc -l`
n_batches=10

# Name of trait

trait=BMI

# Run with j threads

parallel -j 11 --joblog out3.log ~/SiblingGWAS/4.0_unified_regression.sh {1} $trait ::: $(seq 0 $n_batches)

