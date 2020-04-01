with import <nixpkgs> {};

let
  python_packages = p: with p; [
    pip
    virtualenv
    lxml
    python-utils
  ];
  python27 = pkgs.python27.withPackages python_packages;
  python3 = pkgs.python3.withPackages python_packages;
in rec {

  # build and install binaries and vtr_flow
  vtr = stdenv.mkDerivation rec {
    name = "vtr-${version}";
    version = "local";
    buildInputs = [
      bison
      flex
      cmake
      tbb
      xorg.libX11
      xorg.libXft
      fontconfig
      cairo
      pkgconfig
      gtk3
      clang-tools
      gperftools
      perl
      python27
      python3
      time
    ];
    src = fetchGit {
      url = "dusty@hank-wifi:~/src/vtr-verilog-to-routing";
      ref = "master";
    };
  };

  # download benchmarks
  benchmarkDerivation = attrs: stdenv.mkDerivation ({
    buildInputs = [ coreutils ];
    builder = "${bash}/bin/bash";
    args = [ ./benchmarks_builder.sh ];
  } // attrs);
  titan_benchmarks = benchmarkDerivation rec {
    name = "titan_benchmarks-${version}";
    version = "1.3.1";
    src = fetchTarball {
      url = "https://storage.googleapis.com/verilog-to-routing/titan/titan_release_1.3.1.tar.gz";
    };
  };
  ispd_benchmarks = benchmarkDerivation rec {
    name = "ispd_benchmarks-${version}";
    version = "0.0.1";
    src = fetchTarball {
      url = "https://storage.googleapis.com/verilog-to-routing/ispd/ispd_benchmarks_vtr_v0.0.1.tar.gz";
    };
  };

  # list of tasks to run (config.txt) with run_vtr_task
  vtrTaskDerivation = attrs: stdenv.mkDerivation (rec {
    buildInputs = [ vtr perl ];
    builder = "${bash}/bin/bash";
    args = [ ./vtr_task_builder.sh ];
  } // attrs);
  regression_tests = {
    vtr_reg_basic = {
      basic_no_timing = vtrTaskDerivation {
        name = "regression_tests/vtr_reg_basic/basic_no_timing";
      };
    };
  };
}
