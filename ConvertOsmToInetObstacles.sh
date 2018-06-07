#!/bin/bash

# Purpose: This script converts an OpenStreetMap (OSM) map to INET obstacles.
#
# Description: The purpose of obstacles in INET is to simulate real world
# objects such as walls, trees, buildings and hills. Obstacles in INET are used to
# absorb and reflect radio waves, reducing signal quality and decreasing the
# chance of a successful reception. Using this script, you are able to convert
# OSM maps to obstacles and then use them in INET to simulate real world
# buildings and so on.
# If you make use of the veins_inet project you can set the margin variable too.
# Differently, please ignore this parameter and set it to 0.
#
# Author: Panagis Artoumas

# ----------
# Variables |
# ----------

# veins_inet/OMNeT++ settings.
margin=25 # The default value of the veins_inet project.

# -------------------------
# Do some input validation |
# -------------------------

# Check the number of the input arguments.
if (( $# < 3 || $# > 4)); then
    echo -e "Invalid number of arguments. You must pass at least the first 3 arguments.\n\
           - The first is the filename of the net file,\n\
           - The second is the file name of the poly file and\n\
           - The third is the filename of the destination file (e.g. obstacles.xml),\n\
           - Optional: The fourth is the margin variable of the veins_inet project."
	exit 1
fi

# Assign the input arguments to global variables.
netFile=$1
polyFile=$2
destFile=$3

# Check if the net file exists.
if [ ! -f $netFile ]; then
    echo "The given net file doesn't exists."
    exit 1
fi

# Check if the poly file exists.
if [ ! -f $polyFile ]; then
    echo "The given polygon file doesn't exists."
    exit 1
fi

# Check if the margin variable is given as an argument.
if [ ! -z $4 ]; then
    # Check if the margin variable is a number.
    re='^[0-9]+$'
    if [[ $4 =~ $re ]]; then
        margin=$4
    else
        echo "The input margin argument isn't a number. Please insert a number."
        exit 1
    fi
fi

# Check if the destination file exists.
if [ -f $destFile ]; then
    while true
    do
        echo "The destination file already exists. Do you want to overwrite it? (Yy/Nn)"
        read input
        if [ $input = "N" ] || [ $input = "n" ]; then
            exit 0
        elif [ $input = "Y" ] || [ $input = "y" ]; then
            break
        fi
    done
fi

# ------------------------
# Start the conversion :) |
# ------------------------

# Take the boundaries from the net file.
netBoundaries=$(pcregrep -o1 "convBoundary=\"([^\"]*)\"" $netFile | sed 's/,/ /g')
read netBounds1X netBounds1Y netBounds2X netBounds2Y <<< "$netBoundaries"

# Take the boundaries from the poly file.
polyBoundaries=$(pcregrep -o1 "convBoundary=\"([^\"]*)\"" $polyFile)

# Take the shape of the buildings.
shape=$(egrep "^ *<poly.*type=\"(amenity|building)\.?[^\"]*\"" $polyFile |
        pcregrep -o1 "shape=\"([^\"]*)\"" | sed 's/,/ /g')

# Remove the incorrect polygons.
shape=$(echo "$shape" | awk -F ' ' '(NF >= 8){print}')
# Explanation:
# A polygon from OSM has at least 3 points. The first and the last points are equal.
# That's why I check against the 8 and not the 6.

# Calculate the y adjust.
yAdjust=$(echo "$polyBoundaries" | awk -F ',' '{ print $4-$2 }')

# Transform the shape.
shape=$(echo "$shape" | awk -F ' ' -v yAdj=$yAdjust '{for (i=2; i<=NF; i+=2) { $i = yAdj-$i}; print}')

# Find the left corner.
positions=$(echo "$shape" | awk -F ' ' '{xMin=$1; yMin=$2; for(i=3; i<=NF-1; i+=2) { if ($i < xMin) {xMin=$i}; if ($(i+1) < yMin) {yMin=$(i+1)} } print xMin" "yMin }')

positionsAndShapes=$(paste -d ' ' <(echo "$positions") <(echo "$shape"))

finalStr=$(echo "$positionsAndShapes" | awk -F ' ' -v nb1x=$netBounds1X -v nb1y=$netBounds1Y -v nb2x=$netBounds2X -v nb2y=$netBounds2Y -v margin=$margin -v yAdjust=$yAdjust '{printf "<object position=\"min " $1-nb1x+margin " " ((nb2y-nb1y)-(yAdjust-$2-nb1y)+margin) " 0\" "; $1=$2=""; print "shape=\"prism 10 " $0 "\" material=\"brick\" fill-color=\"203 65 84\" opacity=\"0.8\" />" }')

finalStr=$(echo "$finalStr" | sed 's/prism 10 */prism 10 /g' | sed 's/^/\\t/g')

printf "<environment>\n$finalStr\n</environment>" > $destFile
