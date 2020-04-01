set -e

unset PATH
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

cp -r $src/* $out
