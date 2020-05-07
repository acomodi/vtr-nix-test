with import ./default.nix {};

{
  vtr_reg_basic = regression_tests.vtr_reg_basic.all;
  baseline_inner_num_sweep = baseline_inner_num_sweep.all;
}
