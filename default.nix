with import <nixpkgs> {};

let # build custom versions of Python with the packages we need
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
    buildInputs = [ # dependencies
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
      pcre
      harfbuzz
      xorg.libpthreadstubs
      xorg.libXdmcp
      mount
      coreutils
    ];
    src = fetchGit { # get the source using git
      url = "dusty@hank-wifi:~/src/vtr-verilog-to-routing";
    };
    patches = [ ./install_abc.patch ];
    postInstall = ''
      cp -r $src/vtr_flow $out
    '';
  };

  # download benchmarks
  benchmarkDerivation = attrs: stdenv.mkDerivation ({ # common base for benchmark derivations
    buildInputs = [ coreutils gnutar gzip ];
    builder = "${bash}/bin/bash";
    args = [ ./benchmarks_builder.sh ];
  } // attrs);
  titan_benchmarks = benchmarkDerivation rec {
    name = "titan_benchmarks-${version}";
    version = "1.3.1";
    tarball = fetchurl {
      url = "https://storage.googleapis.com/verilog-to-routing/titan/titan_release_1.3.1.tar.gz";
      sha512 = "4beace8286817ecb0abe3cee509fc84f61fe96eafc6cbfe484faa873221677dff50e642e848a89d9e2882da6229b7415253bd3a988b546947ab7ae1a676feaef";
    };
  };
  ispd_benchmarks = benchmarkDerivation rec { # common base for VTR tasks
    name = "ispd_benchmarks-${version}";
    version = "0.0.1";
    tarball = fetchurl {
      url = "https://storage.googleapis.com/verilog-to-routing/ispd/ispd_benchmarks_vtr_v0.0.1.tar.gz";
      sha512 = "215cac150507dedcb4050747940d6f3bd5925432a7c93afe35440438cb77e070be49765e0dd427380b37ac1efc279136fc344e34394c55af32b4db3ffdf6fda7";
    };
  };

  # list of tasks to run (config.txt) with run_vtr_task
  vtrTaskDerivation = flags: test_name: attrs: stdenv.mkDerivation ({
    flags = flags;
    task = test_name;
    name = builtins.replaceStrings ["/"] ["_"] test_name;
    buildInputs = [ time coreutils perl python3 ];
    vtr_flow = "${vtr}/vtr_flow";
    inherit vtr titan_benchmarks ispd_benchmarks coreutils;
    vtr_src = vtr.src;
    builder = "${bash}/bin/bash";
    args = [ ./vtr_task_builder.sh ];
    nativeBuildInputs = [ breakpointHook ]; # debug
  } // attrs);

  # hierarchy matches the directory layout
  mkTests = flags: root: tests:
    builtins.listToAttrs (map (test: {
      name = test;
      value = vtrTaskDerivation flags "${root}/${test}" {};
    }) tests);
  regression_tests = make_regression_tests "";
  make_regression_tests = flags: {
    vtr_reg_basic = mkTests flags "regression_tests/vtr_reg_basic" [
      "basic_no_timing"
      "basic_timing"
      "basic_timing_no_sdc"
    ];
    vtr_reg_strong = mkTests flags "regression_tests/vtr_reg_strong" [
      "strong_cin_tie_off"
      "strong_soft_multipliers"
      "strong_two_chains"
      "strong_dedicated_clock"
      "strong_titan"
      "strong_no_timing"
      "strong_mcnc"
      "strong_flyover_wires"
      "strong_custom_pin_locs"
      "strong_custom_switch_block"
      "strong_custom_grid"
      "strong_place_delay_model"
      "strong_fracturable_luts"
      "strong_fpu_hard_block_arch"
      "strong_timing"
      "strong_depop"
      "strong_router_init_timing"
      "strong_router_update_lb_delays"
      "strong_power"
      "strong_func_formal_flow"
      "strong_func_formal_vpr"
      "strong_bounding_box"
      "strong_breadth_first"
      "strong_echo_files"
      "strong_constant_outputs"
      "strong_sweep_constant_outputs"
      "strong_fix_pins_pad_file"
      "strong_fix_pins_random"
      "strong_global_routing"
      "strong_manual_annealing"
      "strong_pack"
      "strong_pack_and_place"
      "strong_fc_abs"
      "strong_multiclock"
      "strong_minimax_budgets"
      "strong_scale_delay_budgets"
      "strong_verify_rr_graph"
      "strong_verify_rr_graph_bin"
      "strong_analysis_only"
      "strong_route_only"
      "strong_eblif_vpr"
      "strong_default_fc_pinlocs"
      "strong_bidir"
      "strong_detailed_timing"
      "strong_target_pin_util"
      "strong_clock_modeling"
      "strong_unroute_analysis"
      "strong_router_lookahead"
      "strong_eblif_vpr_write"
      "strong_routing_modes"
      "strong_routing_differing_modes"
      "strong_binary"
      "strong_full_stats"
      "strong_global_nonuniform"
      "strong_sdc"
      "strong_timing_report_detail"
      "strong_route_reconverge"
      "strong_clock_buf"
      "strong_equivalent_sites"
      "strong_absorb_buffers"
      "strong_clock_aliases"
    ];
    vtr_reg_nightly = mkTests flags "regression_tests/vtr_reg_nightly" [
      "vpr_reg_mcnc"
      "vtr_reg_qor_chain"
      "vtr_reg_qor_chain_depop"
      "vtr_reg_netlist_writer"
      "vtr_func_formal"
      "titan_quick_qor"
      "titan_other"
      "vtr_bidir"
      "complex_switch"
      "vpr_verify_rr_graph"
      "vpr_verify_rr_graph_bidir"
      "vpr_verify_rr_graph_complex_switch"
      "vpr_verify_rr_graph_titan"
      "vpr_verify_rr_graph_error_check"
    ];
    vtr_reg_weekly = mkTests flags "regression_tests/vtr_reg_weekly" [
      "vtr_reg_titan_he"
      "vtr_reg_titan"
      "vtr_reg_qor_chain_predictor_off"
      "vtr_reg_fpu_hard_block_arch"
      "vtr_reg_fpu_soft_logic_arch"
      "vpr_ispd"
    ];
  };

  # custom configurations
  regression_tests_inner_num_0_5 = make_regression_tests "--inner_num 0.5";
  regression_tests_inner_num_2_0 = make_regression_tests "--inner_num 2.0";
}
