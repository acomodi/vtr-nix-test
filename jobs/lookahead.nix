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
    rev = "04c6b116efb6ab784fad66abfeb454031d0440e8";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "new-extended-lookahead";
    rev = "a89a45544179724cd7eb01c99948ea5683115f9a";
  };

  flags = {
    router_lookahead = "extended_map";
  };

in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_strong;

  changes_regression_tests = (make_regression_tests {
    vtr = vtr_extended_lookahead;
  }).vtr_reg_strong;

  changes_extended_lookahead_regression_tests = (make_regression_tests {
    vtr = vtr_extended_lookahead;
    flags = flags;
  }).vtr_reg_strong;
}
