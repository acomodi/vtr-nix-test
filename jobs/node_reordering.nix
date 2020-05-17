{ ... }: # ignore arguments

with import ../library.nix {
  pkgs = import <nixpkgs> {};
  default_vtr_rev = "06847757816efed89e5216bfaf15c118498bedc4";
}; # import default.nix, passing in nixpkgs

let vtr_node_reordering = vtrDerivation {
      variant = "node_reordering";
      url = "https://github.com/HackerFoo/vtr-verilog-to-routing.git";
      ref = "node_reordering_flag";
      rev = "fb381c011f3b83deb1c63275ee0b923ea9c8151c";
    };
in
summariesOf {
  base = make_regression_tests {};
  node_reordering =
    let test = {flags, ...}:
          (make_regression_tests {
            vtr = vtr_node_reordering;
            flags = flags // {
              reorder_rr_graph_nodes_threshold = 1;
            };
          }).all;
    in
      flag_sweep "node_reordering" test {
        reorder_rr_graph_nodes_algorithm = ["degree_bfs" "random_shuffle"];
      };
}

    
      
