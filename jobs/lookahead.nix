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
    ref = "add-extended-lookahead-map-changes";
    rev = "db9723326194aaa3473a6350ecf6c07f16b4b783";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "add-extended-lookahead-map-changes";
    rev = "380743285feb2c97653077e31869d3ada564eee6";
  };
in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_strong;

  changes_regression_tests = (make_regression_tests {
    vtr = vtr_extended_lookahead;
  }).vtr_reg_strong;
}
