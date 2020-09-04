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
    rev = "fd6191a4868af679a46212edbc1057c8d78bfe7d";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "new-extended-lookahead";
    rev = "9108b1734f54450ad8b7289956de487a7caf1012";
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
