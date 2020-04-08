#!/bin/bash

# Script to import runs into a VTR repo

set -e

VTR_FLOW=~/src/vtr-verilog-to-routing/vtr_flow
TEST_SET=regression_tests/vtr_reg_weekly

n=1
for run in inner_num_sweep/*/vtr_reg_weekly_no_he_inner_num_*; do
  for i in $run/*; do
    task="$TEST_SET/`basename $i`"
    dest="$VTR_FLOW/tasks/$task/`printf "run%03d" $n`"
    echo $dest
    cp -Lrs $PWD/$i $dest
    chmod -R a+w $dest
    $VTR_FLOW/scripts/parse_vtr_task.pl $task
  done
  ((n++))
done
