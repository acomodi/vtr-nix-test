source $stdenv/setup

link_blif_and_sdc() {
    src="$1"
    dst="$2"
    for i in ${src}; do
        dir=`dirname $i`
        base=`basename $i .blif`
        cp -fs ${dir}/${base}.blif ${dst}/${base}.blif
        cp -fs ${dir}/../sdc/vpr.sdc ${dst}/${base}.sdc
    done
}

get_golden() {
    local arch="$1"
    local circuit="$2"
    local script_params="$3"
    local query="$4"

    # read header
    declare -A index
    local header=
    IFS=$'|\n' read -r -a header
    for ((i = 0; i < ${#header[@]}; i++)); do
        index["${header[$i]}"]=$i
    done

    # check header
    if [ -z "${index[arch]}" ] || [ -z "${index[circuit]}" ] || [ -z "${index[${query}]}" ]; then
        return 0
    fi

    # find matching data
    local row=
    while IFS=$'|\n' read -r -a row; do
        if [ "${row[${index[arch]}]}" = "$arch" ] && [ "${row[${index[circuit]}]}" = "$circuit" ]; then
            if [ -z "${index[script_params]}" ] || [ "${row[${index[script_params]}]}" = "$script_params" ]; then
                echo "${row[${index[${query}]}]}"
                return 0
            fi
        fi
    done

    # failed
    return 0
}

# build a lightweight copy of resources needed
# use symlinks when possible
mkdir vpr
mkdir ODIN_II
cp -r $vtr_flow .
cp -s $vtr/bin/vpr vpr
cp -s $vtr/bin/odin_II ODIN_II
cp -r $vtr_src/abc .
cp -r $vtr_src/ace2 .
chmod -R +w .
rm -f abc/abc
cp -s $vtr/bin/abc abc
rm -f ace2/ace
cp -s $vtr/bin/ace ace2

# no /usr/bin/env, so replace with absolute path from coreutils
sed -i "s+/usr/bin/env+$coreutils/bin/env+g" \
  vtr_flow/scripts/run_vtr_{task,flow}.pl \
  ace2/scripts/extract_clk_from_blif.py

# copy arch from titan
for i in $titan_benchmarks/titan_release_*/arch/stratixiv*.xml; do
    dst=vtr_flow/arch/`basename $i`
    cp -f $i $dst
    chmod +w $dst
    ./vtr_flow/scripts/upgrade_arch.py $dst &> /dev/null
    chmod -w $dst
done

# copy blifs and sdcs
link_blif_and_sdc "$titan_benchmarks/titan_release_*/benchmarks/titan23/*/*/*.blif" vtr_flow/benchmarks/titan_blif
link_blif_and_sdc "$titan_benchmarks/titan_release_*/benchmarks/other_benchmarks/*/*/*.blif" vtr_flow/benchmarks/titan_other_blif
cp -s $ispd_benchmarks/ispd_benchmarks_*/benchmarks/*/*.blif vtr_flow/benchmarks/ispd_blif

if [ -e "vtr_flow/tasks/$task/config/golden_results.txt" ]; then
    expected_min_W=`cat "vtr_flow/tasks/$task/config/golden_results.txt" | tr -d ' ' | tr '\t' '|' | get_golden $arch $circuit $script_params_name min_chan_width`
    expected_min_W=$((expected_min_W + expected_min_W % 2))
    if [ $expected_min_W -gt 0 ]; then
        hint="--min_route_chan_width_hint $expected_min_W"
    fi
fi

vtr_flow=$PWD/vtr_flow

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
cp -r * $out

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
