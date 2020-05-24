{ ... }: # ignore arguments

with import ../library.nix {
  pkgs = import <nixpkgs> {};
  default_vtr_rev = "6428b63f06eccf5ead8c27158e22a46b0ad4cd19";
};

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
}

    
      
