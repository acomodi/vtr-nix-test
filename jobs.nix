with import ./default.nix {};

{
  vtr_reg_basic = regression_tests.vtr_reg_basic.all;
  vtr_reg_strong = regression_tests.vtr_reg_strong.all;
  baseline_inner_num_sweep = baseline_inner_num_sweep.all;
}
