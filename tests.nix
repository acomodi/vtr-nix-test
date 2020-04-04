# test runs
#
# configuration for make_regression_tests:
# flags: passed to vpr for each task
# vtr.variant: an identifier for a specific variant
# vtr.url: location of the VTR repo
# vtr.rev: git revision
# vtr.patches: list of patches to apply to VTR
{ make_regression_tests, addAll, ... }:
{
  # default VTR revision
  default_vtr_rev = "508b52fada225670f6ae4f3e053e6bfd39389412";

  # unmodified tests
  regression_tests = make_regression_tests {};

  # a sweep over a few values of --inner_num
  inner_num_sweep = addAll "inner_num_sweep" {
    vtr_reg_weekly_inner_num_0_5  = (make_regression_tests { flags = "--inner_num 0.5"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_1_0  = (make_regression_tests { flags = "--inner_num 1.0"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_2_0  = (make_regression_tests { flags = "--inner_num 2.0"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_5_0  = (make_regression_tests { flags = "--inner_num 5.0"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_10_0 = (make_regression_tests { flags = "--inner_num 10.0"; }).vtr_reg_weekly;
  };
}
