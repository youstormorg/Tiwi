#!/bin/bash
set -euo pipefail

# Set start and end years for the 10-day average
START_YEAR=1980
END_YEAR=1989
TARGET_YEAR=1989  # The year folder where files are copied to usually the same as END_YEAR

# Base paths
BASE_SFC="/scratch/gb02/cc6171/era5/single-levels/reanalysis"
BASE_3D="/scratch/gb02/cc6171/era5/pressure-levels/reanalysis"

# List of variables to process (surface + 3D)
SFC_VARS=(ci sd sp stl1 stl2 stl3 stl4 swvl1 swvl2 swvl3 swvl4 z lsm skt sst)
PL_VARS=(u v q t)

# Compose the 10-day average directory suffix using years
AVG_DIR="10dayav_${START_YEAR}-${END_YEAR}"

# Copy surface variables
for var in "${SFC_VARS[@]}"; do
    src_dir="${BASE_SFC}/${var}/${TARGET_YEAR}/${AVG_DIR}"
    dest_dir="${BASE_SFC}/${var}/${TARGET_YEAR}"
    if [[ -d "$src_dir" ]]; then
        echo "Copying $src_dir  $dest_dir"
        cp -f "$src_dir"/* "$dest_dir"/
    else
        echo "Skipping $var  no $AVG_DIR directory found"
    fi
done

# Copy pressure-level variables
for var in "${PL_VARS[@]}"; do
    src_dir="${BASE_3D}/${var}/${TARGET_YEAR}/${AVG_DIR}"
    dest_dir="${BASE_3D}/${var}/${TARGET_YEAR}"
    if [[ -d "$src_dir" ]]; then
        echo "Copying $src_dir  $dest_dir"
        cp -f "$src_dir"/* "$dest_dir"/
    else
        echo "Skipping $var  no $AVG_DIR directory found"
    fi
done

