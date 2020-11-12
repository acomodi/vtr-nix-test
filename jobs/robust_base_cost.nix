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
    rev = "78e218cbba0fae8771f0cb130bec27122e7a7bf0";
  };

  vtr_default = vtrDerivation {
    variant = "baseline";
    url = "https://github.com/acomodi/vtr-verilog-to-routing.git";
    ref = "robust-delay-norm-factor";
    rev = "2efa8d0bff34688a02b4fec7e0b5b7d44824f6c1";
  };

in
summariesOf {
  base_regression_tests = (make_regression_tests {
    vtr = vtr_default;
  }).vtr_reg_nightly.titan_quick_qor;

  changes_regression_tests = (make_regression_tests {
    vtr = vtr_base_cost_histogram;
  }).vtr_reg_nightly.titan_quick_qor;
}
