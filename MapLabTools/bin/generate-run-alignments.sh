#!/bin/bash

function usage() {
  cat << EOF

Usage: generate-run-alignments.sh

  generate-run-alignments -b <baseDir> -r <reference run> <run-list>
  
    -b base directory that contains the run folders r003, r004... etc
    -r reference run folder name. The one you want to align all other runs to 

    example:  align all runs to run 3, which is closest to the anat (r002)

    generate-run-alignments -b /Users/test/my-fmri-data/SUBJ_ID -r 003 004 006 008 010  


EOF
  exit 1  
}

function error_msg() {
  echo
  echo "*****  $1  *****"
  usage
}

# take input and make sure we get full path
function get_fullpath() {
  ( cd "$1"; echo `pwd` ) 2> /dev/null
}

###############################################################################



baseDir=""
ref=""
declare -a runs

# process input args using getopts
while getopts ":b:r:" opt; do
  case $opt in 
    b)
      # just a fancy way of making sure we get the full path 
      baseDir="$OPTARG"
      ;;
    r)
      ref="$OPTARG"
      ;;
    h) 
      usage
      ;;
    \?)
      error_msg "Invalid option: -$OPTARG" >&2
      ;;
  esac
done
# asign runs
shift $((OPTIND -1))
runs=("$@")


# check that supplied args are good

if [ -z "$baseDir" ] || [ ! -d "$baseDir" ]; then
  error_msg "Error: the supplied base directory \"$baseDir\" does not exist"
fi

if [ -z "$ref" ] || [ ! -d "$( get_fullpath $baseDir/$ref )" ]; then
  error_msg "Error: reference directory \"$ref\" inside \"$baseDir\" does not exist" >&2
fi

if [ "$#" -lt 1 ]; then
  error_msg "Error: you must supply at least 1 directory" >&2
fi

echo "baseDir: $baseDir"
echo "ref: $ref"
echo "runs: ${runs[@]}"


targetDir="$baseDir/run-alignment"
mkdir "$targetDir"

# generate 1st vol for reference image
fn=$(cat "$baseDir/$ref/design.fsf" | grep 'set feat_files(1)' | sed -n 's/.*\"\(.*\)\".*/\1/p' )
if [ -z "$fn" ]; then
  echo "error: couldn't extract base filename for series $r from the design.fsf"
  exit 1
fi

# get current vol
$FSLDIR/bin/fslroi "$fn" "$targetDir/${ref}_firstvol" 0 1 


# extract the first volume from each series then save off as 's###_firstvol'
for r in "${runs[@]}"; do

  echo "processing $r ...."
  
  if [ "$r" != "$ref" ]; then

    # extract current seriese filre from design.fsf
    fn=$(cat "$baseDir/$r/design.fsf" | grep 'set feat_files(1)' | sed -n 's/.*\"\(.*\)\".*/\1/p' )
    if [ -z "$fn" ]; then
      echo "error: couldn't extract base filename for series $r from the design.fsf"
      exit 1
    fi

    # extract first vol
    $FSLDIR/bin/fslroi "$fn" "$targetDir/${r}_firstvol" 0 1 
    
    # generate transf. from current run to highres then concat from highres to reference.
    $FSLDIR/bin/convert_xfm \
      -omat  "${targetDir}/${r}_firstvol-to-${ref}_firstvol.mat" \
      -concat "${baseDir}/${ref}/analysis.feat/reg/highres2example_func.mat" \
      "$baseDir/$r/analysis.feat/reg/example_func2highres.mat"

    # register first vol to reference series
    $FSLDIR/bin/flirt \
      -in "$targetDir/${r}_firstvol" \
      -ref "$targetDir/${ref}_firstvol" \
      -interp sinc \
      -init "$targetDir/${r}_firstvol-to-${ref}_firstvol.mat" \
      -applyxfm \
      -out "$targetDir/${r}_firstvol-to-${ref}_firstvol"

    # register functional volumes for comparison
    $FSLDIR/bin/flirt \
      -in $targetDir/${r}_firstvol \
      -ref $targetDir/${ref}_firstvol \
      -interp sinc \
      -out "$targetDir/${r}_firstvol-to-${ref}_firstvol-func"

  fi

done
