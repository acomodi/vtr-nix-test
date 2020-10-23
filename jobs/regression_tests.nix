{ ... }: # ignore arguments

with import ../library.nix {
  default_vtr_rev = "ab5f508db7e405925a45d1da918e6dca78730b44";
  pkgs = import <nixpkgs> {}; # import default.nix, passing in nixpkgs
};

let
  regression_tests = make_regression_tests {};
in

# each attribute is a job
summariesOf {
  vtr_reg_basic = regression_tests.vtr_reg_basic;
  vtr_reg_strong = regression_tests.vtr_reg_strong;
  vtr_reg_nightly = regression_tests.vtr_reg_nightly;
  vtr_reg_weekly = regression_tests.vtr_reg_weekly;
}
