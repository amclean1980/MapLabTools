#!/bin/bash

regions[0]="7_Precentral-gyrus-M1"
regions[1]="17_Postcentral-gyrus-S1"
regions[2]="18_Superior-parietal-lobule"
regions[3]="24_Intracalcerine"
regions[4]="31_Precuneous"
regions[5]="45_Heschels-gyrus-H1-H2"
regions[6]="47_Supracalcerine"
regions[7]="48_Occipital-pole"

if [ $# -eq 0 ]; then
  outDir=`pwd`
elif [ $# -eq 1 ]; then
  outdir="$1"
else
  echo "error: either input the target dir or nothing for current"
fi

# copy the atlas
cp $FSLDIR/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr0-2mm.nii.gz "$outDir/atlas.nii.gz"

# create hemisphere masks
$FSLDIR/bin/fslmaths "$outDir/atlas.nii.gz" -bin -roi 0 45 -1 -1 -1 -1 -1 -1 "$outDir/right-hemi"
$FSLDIR/bin/fslmaths "$outDir/atlas.nii.gz" -bin -roi 45 -1 -1 -1 -1 -1 -1 -1 "$outDir/left-hemi"

for r in {0..7}; do 
  num=$( echo ${regions[$r]} | cut -d '_' -f 1 )
  lab=$( echo ${regions[$r]} | cut -d '_' -f 2 )
  echo "$r) $num -> $lab"
  $FSLDIR/bin/fslmaths "$outDir/atlas.nii.gz" \
    -thr $num -uthr $num -mas "$outDir/left-hemi" "$outDir/left-$lab_standard"

  $FSLDIR/bin/flirt 
  

  $FSLDIR/bin/fslmaths "$outDir/atlas.nii.gz" \
    -thr $num -uthr $num -mas "$outDir/left-hemi" -ero -kernel sphere 3 "$outDir/left-$lab-ero3_standard"
  $FSLDIR/bin/fslmaths "$outDir/atlas.nii.gz" \
    -thr $num -uthr $num -mas "$outDir/right-hemi" "$outDir/right-$lab_standard"
  $FSLDIR/bin/fslmaths "$outDir/atlas.nii.gz" \
    -thr $num -uthr $num -mas "$outDir/right-hemi" -ero -kernel sphere 3 "$outDir/right-$lab-ero3_standard"

done

