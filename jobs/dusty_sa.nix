{
  pkgs ? import <nixpkgs> {}
}:

with import ../library.nix {
  inherit pkgs;
  default_vtr_rev = "6428b63f06eccf5ead8c27158e22a46b0ad4cd19";
};

with pkgs.lib;

let vtr_dusty_sa = vtrDerivation {
      variant = "dusty_sa";
      url = "https://github.com/HackerFoo/vtr-verilog-to-routing.git";
      ref = "dusty_sa";
      rev = "d7930ad06d99008c055f37de9e60d244f0590d71";
    };
in
summariesOf {
  no_flag_regression_tests = make_regression_tests {
    vtr = vtr_dusty_sa;
  };
  no_flag_regression_seeds = let
    test = { flags, ... }:
      (make_regression_tests {
        vtr = vtr_dusty_sa;
        inherit flags;
      }).vtr_reg_nightly;
  in
    flag_sweep "no_flag_regression_seeds" test {
      seed = range 32 64;
    };
}

    
      
