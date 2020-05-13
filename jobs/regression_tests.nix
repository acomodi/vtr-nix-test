{ ... }: # ignore arguments

with import ../default.nix { pkgs = import <nixpkgs> {}; }; # import default.nix, passing in nixpkgs

# each attribute is a job
{
  vtr_reg_basic = regression_tests.vtr_reg_basic.summary;
  vtr_reg_strong = regression_tests.vtr_reg_strong.summary;
}
