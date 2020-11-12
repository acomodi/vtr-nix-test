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
    ref = "robust-delay-norm-factor";
    rev = "5c0393eb7280803ce3a8b29ad2bafa3fff841e3e";
  };

  vtr_base_cost_histogram_higher_delay_astar = vtrDerivation {
    variant = "robust_base_cost";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor";
    rev = "1a239e6a9eae5bdbe783192bbc1278bd1027b614";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor";
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

  changes_regression_tests_higher_astar = (make_regression_tests {
    vtr = vtr_base_cost_histogram_higher_delay_astar;
  }).vtr_reg_nightly.titan_quick_qor;
}
