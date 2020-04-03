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

cd vtr_flow

# run the task
./scripts/run_vtr_task.pl $task -j $NIX_BUILD_CORES -s $flags

# remove references
find tasks/$task/latest/ -type f -print0 | xargs -0 sed -i \
  -e "s+$coreutils+\$coreutils+g" \
  -e "s+$titan_benchmarks+\$titan_benchmarks+g" \
  -e "s+$ispd_benchmarks+\$ispd_benchmarks+g"

# store the results
mkdir -p $out
cp -r tasks/$task/latest/* $out
echo "$task" > $out/task_name
echo "$flags" > $out/task_flags
cp "$vtr/opts" $out/vtr_opts

