{
  pkgs ? import <nixpkgs> {}
}:

with import ../library.nix {
  inherit pkgs;
  default_vtr_rev = "380743285feb2c97653077e31869d3ada564eee6";
};

with pkgs.lib;

let
  vtr_extended_lookahead = vtrDerivation {
    variant = "extended_lookahead";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "new-extended-lookahead";
    rev = "66990676a9350f6725b65490f45a3aa173de4a39";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "new-extended-lookahead";
    rev = "b7789e56ac4fa5f3daf6f4d4ce5fe821b365bf08";
  };

  flags = {
    router_lookahead = "extended_map";
  };

in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests = (make_regression_tests {
    vtr = vtr_extended_lookahead;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_extended_lookahead_regression_tests = (make_regression_tests {
    vtr = vtr_extended_lookahead;
    flags = flags;
  }).vtr_reg_nightly.titan_quick_qor;
}
