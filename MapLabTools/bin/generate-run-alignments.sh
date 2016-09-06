#!/bin/bash

declare -a runs

if [ $# -eq "0" ]; then 
  exit 1
fi

while (("$#" > 0)); do
  if [ "$1" == "-dir" ]; then
    shift
    baseDir="$1"
    shift
  elif [ "$1" == "-ref" ]; then
    shift
    ref=$1
    shift
    runs=( "$@" )
  else
    runs=( "$@" )
    ref=${runs[0]}
    break
  fi
done

targetDir="$baseDir/run-alignment"
mkdir "$targetDir"

echo "ref: $ref"
echo "runs: ${runs[@]}"

# generate 1st vol for reference image
fn=$(cat "$baseDir/$ref/design.fsf" | grep 'set feat_files(1)' | sed -n 's/.*\"\(.*\)\".*/\1/p' )
if [ -z "$fn" ]; then
  echo "error: couldn't extract base filename for series $r from the design.fsf"
  exit 1
fi

# get current vol
$FSLDIR/bin/fslroi "$fn" "$targetDir/s${ref}_firstvol" 0 1 


# extract the first volume from each series then save off as 's###_firstvol'
for r in "${runs[@]}"; do

  echo "processing $r ...."
  
  if [ "$r" -ne "$ref" ]; then

    # extract current seriese filre from design.fsf
    fn=$(cat "$baseDir/$r/design.fsf" | grep 'set feat_files(1)' | sed -n 's/.*\"\(.*\)\".*/\1/p' )
    if [ -z "$fn" ]; then
      echo "error: couldn't extract base filename for series $r from the design.fsf"
      exit 1
    fi

    # extract first vol
    $FSLDIR/bin/fslroi "$fn" "$targetDir/s${r}_firstvol" 0 1 
    
    # generate transf. from current run to highres then concat from highres to reference.
    $FSLDIR/bin/convert_xfm \
      -omat  "${targetDir}/s${r}_firstvol-to-s${ref}_firstvol.mat" \
      -concat "${baseDir}/${ref}/analysis.feat/reg/highres2example_func.mat" \
      "$baseDir/$r/analysis.feat/reg/example_func2highres.mat"

    # register first vol to reference series
    $FSLDIR/bin/flirt \
      -in "$targetDir/s${r}_firstvol" \
      -ref "$targetDir/s${ref}_firstvol" \
      -interp sinc \
      -init "$targetDir/s${r}_firstvol-to-s${ref}_firstvol.mat" \
      -applyxfm \
      -out "$targetDir/s${r}_firstvol-to-s${ref}_firstvol"

    # register functional volumes for comparison
    $FSLDIR/bin/flirt \
      -in $targetDir/s${r}_firstvol \
      -ref $targetDir/s${ref}_firstvol \
      -interp sinc \
      -out "$targetDir/s${r}_firstvol-to-s${ref}_firstvol-func"

  fi

done
