with import <nixpkgs> {};

let # build custom versions of Python with the packages we need
  inherit (lib.attrsets) mapAttrsToList;
  python_packages = p: with p; [
    pip
    virtualenv
    lxml
    python-utils
  ];
  python27 = pkgs.python27.withPackages python_packages;
  python3 = pkgs.python3.withPackages python_packages;
  self = rec {

    # build and install binaries and vtr_flow
    vtr = { url ? "https://github.com/verilog-to-routing/vtr-verilog-to-routing.git", # git repo
            variant ? "verilog-to-routing", # identifier
            ref ? "HEAD", # git ref
            rev ? tests.default_vtr_rev, # specific revision
            patches ? [] # any patches to apply
          }: stdenv.mkDerivation {
            name = "vtr-${variant}-${rev}";
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
              url = url;
              ref = ref;
              rev = rev;
            };
            patches = [ ./install_abc.patch ] ++ patches;
            postInstall = ''
            cp -r $src/vtr_flow $out
            echo "variant: ${variant}" > $out/opts
            echo "url:     ${url}"    >> $out/opts
            echo "ref:     ${ref}"    >> $out/opts
            echo "rev:     ${rev}"    >> $out/opts
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
    # opts.flags: flags passed tp vpr
    # opts.
    pathToName = builtins.replaceStrings ["/"] ["_"];
    vtrTaskDerivation = opts: test_name: attrs: stdenv.mkDerivation (
      let custom_vtr = vtr (if opts ? vtr then opts.vtr else {});
      in {
        flags = if opts ? flags then opts.flags else "";
        task = test_name;
        name = pathToName test_name;
        buildInputs = [ time coreutils perl python3 ];
        vtr_flow = "${custom_vtr}/vtr_flow";
        inherit titan_benchmarks ispd_benchmarks coreutils;
        vtr = custom_vtr;
        vtr_src = custom_vtr.src;
        builder = "${bash}/bin/bash";
        args = [ ./vtr_task_builder.sh ];
        nativeBuildInputs = [ breakpointHook ]; # debug
      } // attrs);

    # adds an .all derivation that links to all the other derivations in the set
    addAll = root: tests:
      let f = name: val: {
            name = name;
            path = if builtins.typeOf val == "set" then val.all else val;
          };
      in
        tests // {
          all = linkFarm "${root}_all" (mapAttrsToList f tests);
        };

    # hierarchy matches the directory layout
    mkTests = opts: root: tests:
      addAll (pathToName root) (builtins.listToAttrs (map (test: {
        name = test;
        value = vtrTaskDerivation opts "${root}/${test}" {};
      }) tests));

    # make a custom set of regression tests
    make_regression_tests = import ./make_regression_tests.nix self;

    # import tests
    tests = import ./tests.nix self;
  };
in self
