{
  pkgs ? import <nixpkgs> {}
}:

with import ../library.nix {
  inherit pkgs;
  default_vtr_rev = "461f8539372b36492d88e58a7b9675ebfe703760";
};

with pkgs.lib;

let
  vtr_base_cost = vtrDerivation {
    variant = "extended_lookahead";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor";
    rev = "4c55d01eb694758c0def39a3daec57f2329fe0c3";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor";
    rev = "ab5f508db7e405925a45d1da918e6dca78730b44";
  };

in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests = (make_regression_tests {
    vtr = vtr_base_cost;
  }).vtr_reg_nightly.titan_quick_qor;
}
