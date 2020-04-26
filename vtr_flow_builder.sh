source $stdenv/setup

ln -s $vtr_test_setup/* .
vtr_flow=$vtr/vtr_flow

if [ -e "$vtr_flow/tasks/$task/config/golden_results.txt" ]; then
    expected_min_W=`$python/bin/python $get_param $vtr_flow/tasks/$task/config/golden_results.txt $arch $circuit $script_params_name min_chan_width`
    expected_min_W=$((expected_min_W + expected_min_W % 2))
    if [ $expected_min_W -gt 0 ]; then
        hint="--min_route_chan_width_hint $expected_min_W"
    fi
fi

# run the task
mkdir -p run
cd run
cat <<EOF > vtr_flow.sh
../vtr_flow/scripts/run_vtr_flow.pl \
../vtr_flow/$circuits_dir/$circuit \
../vtr_flow/$archs_dir/$arch \
-temp_dir . \
$script_params_common \
$script_params \
$hint \
$flags
EOF
bash vtr_flow.sh |& tee vtr_flow.out || true # don't abort on failure

# parse the results
if [ -n "$parse_file" ]; then
    $vtr_flow/scripts/parse_vtr_flow.pl . $vtr_flow/parse/parse_config/$parse_file arch=$arch circuit=$circuit script_params=$script_params_name > parse_results.txt || true
fi
if [ -n "$qor_parse_file" ]; then
    $vtr_flow/scripts/parse_vtr_flow.pl . $vtr_flow/parse/qor_config/$qor_parse_file > qor_results.txt || true
fi

# remove references
find . -type f -name '*.out' -print0 | xargs -0 sed -i \
  -e "s+$coreutils+\$coreutils+g" \
  -e "s+$titan_benchmarks+\$titan_benchmarks+g" \
  -e "s+$ispd_benchmarks+\$ispd_benchmarks+g"

# store the results
mkdir -p $out

# copy all but the largest files
cp !(*.net|*.route|*.blif) $out

# record parameters
cat <<EOF > $out/params
task: $task
flags: $flags
run_id: $run_id
arch: $arch
circuit: $circuit
script_params_common: $script_params_common
script_params: $script_params
hint: $hint
EOF
cp "$vtr/opts" $out/vtr_opts
