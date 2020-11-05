{
  pkgs ? import <nixpkgs> {}
}:

with import ../library.nix {
  inherit pkgs;
  default_vtr_rev = "461f8539372b36492d88e58a7b9675ebfe703760";
};

with pkgs.lib;

let
  vtr_base_cost_4x = vtrDerivation {
    variant = "extended_lookahead";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "test-4x-delay-fac";
    rev = "d151cab5a612af73ce416b4dfc0f0fac6dbcd502";
  };

  vtr_base_cost_3x = vtrDerivation {
    variant = "extended_lookahead";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "test-3x-delay-factor";
    rev = "7d08c066b2135d85fded40445222ef253eb0868d";
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

  delay_norm_4x_regression_tests = (make_regression_tests {
    vtr = vtr_base_cost_4x;
  }).vtr_reg_nightly.titan_quick_qor;

  delay_norm_3x_regression_tests = (make_regression_tests {
    vtr = vtr_base_cost_3x;
  }).vtr_reg_nightly.titan_quick_qor;
}
