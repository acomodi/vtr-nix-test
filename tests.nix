# test runs
#
# configuration for make_regression_tests:
# flags: passed to vpr for each task
# vtr.variant: an identifier for a specific variant
# vtr.url: location of the VTR repo
# vtr.rev: git revision
# vtr.patches: list of patches to apply to VTR
{ lib, make_regression_tests, addAll, vtrDerivation, nameStr, ... }:

with lib;

rec {
  # default VTR revision
  default_vtr_rev = "6428b63f06eccf5ead8c27158e22a46b0ad4cd19";

  # unmodified tests
  regression_tests = make_regression_tests {};

  vtr_dusty_sa = vtrDerivation {
    variant = "dusty_sa";
    url = "https://github.com/HackerFoo/vtr-verilog-to-routing.git";
    ref = "dusty_sa";
    rev = "b46fd7d22f25fb0f787ce2e7217d44f4960aad6b";
  };

  vtr_node_reordering = vtrDerivation {
    variant = "node_reordering_flag";
    url = "https://github.com/HackerFoo/vtr-verilog-to-routing.git";
    ref = "node_reordering_flag";
    rev = "7872c8f6cb32efb988138b50e3caf198bb2212ac";
  };

  # a sweep over a few values of --inner_num
  dot_to_us = builtins.replaceStrings ["."] ["_"];
  make_inner_num_sweep = test_type: fn: values: builtins.listToAttrs (map (val: {
    name = "${test_type}_inner_num_${dot_to_us val}";
    value = (make_regression_tests (fn val)).${test_type};
  }) values);
  make_inner_num_sweep_comparison = test_type: values: opts: addAll "inner_num_sweep_${test_type}" {
    baseline = addAll "baseline" (make_inner_num_sweep test_type (val: { flags = "--inner_num ${val}"; } // opts) values);
    no_flag = addAll "no_flag" (make_inner_num_sweep test_type (val: { vtr = vtr_dusty_sa; flags = "--inner_num ${val}"; } // opts) values);
    with_flag = addAll "with_flag" (make_inner_num_sweep test_type (val: { vtr = vtr_dusty_sa; flags = "--alpha_min 0.2 --inner_num ${val}"; } // opts) values);
  };
  inner_num_sweep_weekly = make_inner_num_sweep_comparison "vtr_reg_weekly_no_he" ["0.5" "1.0" "2.0"] { };
  inner_num_sweep_nightly = make_inner_num_sweep_comparison "vtr_reg_nightly" ["0.125" "0.25" "0.5" "1.0" "2.0"] { run_id = "1"; };
  inner_num_sweep_nightly_2 = make_inner_num_sweep_comparison "vtr_reg_nightly" ["0.125" "0.25" "0.5" "1.0" "2.0"] { run_id = "2"; };
  inner_num_sweep_nightly_3 = make_inner_num_sweep_comparison "vtr_reg_nightly" ["0.125" "0.25" "0.5" "1.0" "2.0"] { run_id = "3"; };
  dusty_sa = make_regression_tests { vtr = vtr_dusty_sa; flags = "--alpha_min 0.2"; };
  node_reordering = make_regression_tests { vtr = vtr_node_reordering; flags = "--reorder_rr_graph_nodes_threshold 1 --reorder_rr_graph_nodes_algorithm degree_bfs"; };
  node_reordering_random = make_regression_tests { vtr = vtr_node_reordering; flags = "--reorder_rr_graph_nodes_threshold 1 --reorder_rr_graph_nodes_algorithm random_shuffle"; };
  node_reordering_off = make_regression_tests { vtr = vtr_node_reordering; };
  inner_num_sweep_with_flag_high = addAll "with_flag" (make_inner_num_sweep "vtr_reg_nightly" (val: { run_id = "with_flag_high"; vtr = vtr_dusty_sa; flags = "--alpha_min 0.2 --inner_num ${val}"; }) ["4.0" "10.0"]);

  # flag_sweep :: root -> attrs -> ({root, flags} -> derivation) -> derivations
  flag_sweep = root: test: attrs:
    foldl (test: flag:
      {root, flags}:
      addAll root (listToAttrs (map (value:
        let name = nameStr "${flag} ${value}"; in
        {
          inherit name;
          value = test {
            root = "${root}_${name}";
            flags = "${flags} --${flag} ${value}";
          };
        }) (getAttr flag attrs)))) test (attrNames attrs) { inherit root; flags = ""; };

  dusty_sa_sweep =
    let test = {root, flags}:
          (make_regression_tests {
            vtr = vtr_dusty_sa;
            inherit flags;
          }).vtr_reg_nightly.titan_quick_qor.all;
    in
    flag_sweep "dusty_sa_sweep" test {
      alpha_min = ["0.1" "0.2" "0.5" "0.8"];
      alpha_max = ["0.9" "0.95"];
      alpha_decay = ["0.9" "0.7" "0.5"];
      anneal_success_target = ["0.15" "0.25" "0.4"];
      anneal_success_min = ["0.05" "0.1"];
    };
}
