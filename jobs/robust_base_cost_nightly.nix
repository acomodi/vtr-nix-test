{
  pkgs ? import <nixpkgs> {}
}:

with import ../library.nix {
  inherit pkgs;
  default_vtr_rev = "461f8539372b36492d88e58a7b9675ebfe703760";
};

with pkgs.lib;

let
  vtr_base_cost_double_pres_fac = vtrDerivation {
    variant = "extended_lookahead";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-base-cost-double-pres-fac";
    rev = "152f2e71dea17a26329f51a85498321031f2fc75";
  };

  vtr_base_cost_astar_fac = vtrDerivation {
    variant = "extended_lookahead";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-base-cost-double-pres-fac";
    rev = "0022263a62920ef03139f7e7b947aea20d438f36";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-base-cost-double-pres-fac";
    rev = "236bfcd720e163ab3853d8500fa9cfa222a3240c";
  };

in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_double_pres_fac = (make_regression_tests {
    vtr = vtr_base_cost_double_pres_fac;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_high_astar_fac = (make_regression_tests {
    vtr = vtr_base_cost_astar_fac;
  }).vtr_reg_nightly.titan_quick_qor;
}
