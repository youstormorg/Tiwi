#!/bin/bash
#PBS -P gb02
#PBS -q normal
#PBS -l ncpus=1
#PBS -l mem=64GB
#PBS -l walltime=12:00:00
#PBS -l jobfs=100GB
#PBS -N era5_10dayav_20yr
#PBS -l storage=gdata/rt52+scratch/gb02

###############################################################################
# Script: era5_10dayav_20yr.sh
#
# Purpose:
#   Create a 20-year (2000–2019) ERA5 mid-November 10-day (10–19 Nov)
#   average diurnal cycle for both pressure-level and surface variables.
#   Output is saved in /scratch/gb02/cc6171/.../10dayav20yr
#
# Usage:
#   qsub era5_10dayav_20yr.sh
#
# Notes:
#   - Requires ERA5 data from /g/data/rt52
#   - Processes each variable independently to reduce memory use
#   - Resets time axis to 12 Dec 2016 for ACCESS-rAM3 compatibility
###############################################################################

module load cdo

# Years to process
years=$(seq 2000 2019)

# Output base directory
outbase="/scratch/gb02/cc6171/era5"

# Region subset (Tiwi Islands + buffer, adjust as needed)
lonW=125
lonE=140
latS=-15
latN=-5

# Pressure-level variables
pl_vars=("u" "v" "q" "t")
pl_dir="pressure-levels/reanalysis"

# Single-level variables
sfc_vars=("ci" "sd" "sp" "stl1" "stl2" "stl3" "stl4" \
          "swvl1" "swvl2" "swvl3" "swvl4" \
          "z" "lsm" "skt" "sst")
sfc_dir="single-levels/reanalysis"

###############################################################################
process_var() {
    local var=$1
    local indir=$2
    local outdir=$3

    mkdir -p "$outdir"
    tmpfiles=()

    echo "[INFO] Processing $var ..."

    # Loop over all years, subset spatially and temporally
    for y in $years; do
        infile="/g/data/rt52/era5/${indir}/${var}/${y}/${var}_era5_oper_$( [[ $indir == $pl_dir ]] && echo pl || echo sfc )_${y}11*.nc"
        outfile="${outdir}/${var}_${y}_subset.nc"

        # Select region + date range
        cdo sellonlatbox,${lonW},${lonE},${latS},${latN} $infile tmp1.nc
        cdo seldate,${y}-11-10,${y}-11-19 tmp1.nc "$outfile"
        rm -f tmp1.nc

        tmpfiles+=("$outfile")
    done

    # Merge all years
    cdo mergetime "${tmpfiles[@]}" merged.nc

    # Compute diurnal mean
    cdo -dhourmean merged.nc diurnal.nc

    # Reset time axis to match ACCESS-rAM3 expectations
    cdo settaxis,2016-12-12,00:00:00,1hour diurnal.nc "${outdir}/${var}_10dayav20yr.nc"

    # Clean up
    rm -f merged.nc diurnal.nc "${tmpfiles[@]}"
    echo "[INFO] Finished $var"
}

###############################################################################
# Process pressure-level variables
for var in "${pl_vars[@]}"; do
    process_var "$var" "$pl_dir" "${outbase}/${pl_dir}/${var}/10dayav20yr"
done

# Process single-level variables
for var in "${sfc_vars[@]}"; do
    process_var "$var" "$sfc_dir" "${outbase}/${sfc_dir}/${var}/10dayav20yr"
done

echo "[INFO] All variables processed successfully."
###############################################################################
