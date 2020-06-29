#!/bin/sh

numb=42
warp='$numb'  # NOT doublequotes

echo $numb
echo $warp
# Force evaluation.
eval echo $warp
