set -e

root=~/src/vtr-nix-test
test_data=inner_num_sweep_nightly_1
test_set=vtr_reg_nightly
test=titan_quick_qor
vtr_root=~/src/vtr-verilog-to-routing
analysis_dir=${root}/${test_data}_analysis

mkdir -p ${root}/${test_data}_analysis
for i in baseline no_flag with_flag; do
  for j in 0_125 0_25 0_5 1_0 2_0; do
    ln -sf ${root}/${test_data}/${i}/${test_set}_inner_num_${j}/${test}/parse_results.txt ${analysis_dir}/${i}_${j}_results.txt
  done
done

(
  cd $vtr_root
  ./vtr_flow/scripts/qor_compare.py \
    ${analysis_dir}/baseline_{1_0,0_125,0_25,0_5,2_0}_results.txt \
    ${analysis_dir}/{no_flag,with_flag}_{0_125,0_25,0_5,1_0,2_0}_results.txt \
    -o ${analysis_dir}/${test_data}_comparison.xlsx
)
