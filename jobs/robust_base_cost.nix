{
  pkgs ? import <nixpkgs> {}
}:

with import ../library.nix {
  inherit pkgs;
  default_vtr_rev = "461f8539372b36492d88e58a7b9675ebfe703760";
};

with pkgs.lib;

let
  vtr_base_cost_histogram = vtrDerivation {
    variant = "robust_base_cost";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "057650382e99d5938833a8de04496c3c9660f5e2";
  };
  
  vtr_base_cost_defaults = vtrDerivation {
    variant = "robust_base_cost";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "b55ba816194aa9280de06b1c415473e72933795c";
  };

  vtr_base_cost_histogram_higher_delay_astar = vtrDerivation {
    variant = "robust_base_cost";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "22084174e52bbe2c4f548bda47db9e07aafa5ba4";
  };

  vtr_base_cost_histogram_higher_delay_astar_1_4 = vtrDerivation {
    variant = "robust_base_cost";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "09e609679022f67c955a59e864a3eba1edb93369";
  };

  vtr_base_cost_histogram_higher_delay_astar_1_3 = vtrDerivation {
    variant = "robust_base_cost";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "9340175d4e57fcf1582d222d89531ece3bdb2e36";
  };

  vtr_double_pres_fac = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "363e99f51e7daefd5031ad8e4a974afe96e2db13";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor-double-pres-fac";
    rev = "00a7efdeb49aafd61d2eed7834bccc6110f3160d";
  };

in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests = (make_regression_tests {
    vtr = vtr_base_cost_histogram;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests_defaults = (make_regression_tests {
    vtr = vtr_base_cost_defaults;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests_higher_astar = (make_regression_tests {
    vtr = vtr_base_cost_histogram_higher_delay_astar;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests_higher_astar_double_pres_fac = (make_regression_tests {
    vtr = vtr_double_pres_fac;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests_higher_astar_1_4 = (make_regression_tests {
    vtr = vtr_base_cost_histogram_higher_delay_astar_1_4;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests_higher_astar_1_3 = (make_regression_tests {
    vtr = vtr_base_cost_histogram_higher_delay_astar_1_3;
  }).vtr_reg_nightly.titan_quick_qor;
}
