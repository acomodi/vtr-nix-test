# test runs
#
# configuration for make_regression_tests:
# flags: passed to vpr for each task
# vtr.variant: an identifier for a specific variant
# vtr.url: location of the VTR repo
# vtr.rev: git revision
# vtr.patches: list of patches to apply to VTR
{ make_regression_tests, addAll, ... }:
rec {
  # default VTR revision
  default_vtr_rev = "508b52fada225670f6ae4f3e053e6bfd39389412";

  # unmodified tests
  regression_tests = make_regression_tests {};

  vtr_dusty_sa = {
    variant = "dusty_sa";
    url = "https://github.com/HackerFoo/vtr-verilog-to-routing.git";
    ref = "dusty_sa";
    rev = "9015e80d490ad707c88e851b97ada71d44c8037e";
  };

  # a sweep over a few values of --inner_num
  test_type = "vtr_reg_weekly_no_he";
  dot_to_us = builtins.replaceStrings ["."] ["_"];
  inner_num_values = ["0.5" "1.0" "2.0"];
  make_inner_num_sweep = fn: builtins.listToAttrs (map (val: {
    name = "${test_type}_inner_num_${dot_to_us val}";
    value = (make_regression_tests (fn val)).${test_type};
  }) inner_num_values);
  inner_num_sweep = addAll "inner_num_sweep" {
    baseline = addAll "baseline" (make_inner_num_sweep (val: { flags = "--inner_num ${val}"; }));
    no_flag = addAll "no_flag" (make_inner_num_sweep (val: { vtr = vtr_dusty_sa; flags = "--inner_num ${val}"; }));
    with_flag = addAll "with_flag" (make_inner_num_sweep (val: { vtr = vtr_dusty_sa; flags = "--alpha_min 0.2 --inner_num ${val}"; }));
  };
}
