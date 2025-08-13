#!/bin/bash
#PBS -P gx60
#PBS -q normal
#PBS -l walltime=04:00:00
#PBS -l mem=32GB
#PBS -l ncpus=8
#PBS -l storage=gdata/rt52+scratch/gb02
#PBS -N era5_10dayav_1980_1989
#PBS -o /scratch/gb02/cc6171/logs/era5_10dayav_1980_1989.o
#PBS -e /scratch/gb02/cc6171/logs/era5_10dayav_1980_1989.e

set -euo pipefail

module load cdo

VARS_3D=("u" "v" "q" "t")
VARS_SFC=("ci" "sd" "sp" "stl1" "stl2" "stl3" "stl4" \
          "swvl1" "swvl2" "swvl3" "swvl4" "z" "lsm" "skt" "sst")

YEARS=$(seq 1980 1989)

BASEDIR_3D="/g/data/rt52/era5/pressure-levels/reanalysis"
BASEDIR_SFC="/g/data/rt52/era5/single-levels/reanalysis"

OUTBASE="/scratch/gb02/cc6171/era5"
TMPDIR="/scratch/gb02/cc6171/tmp_10dayav_1980_1989"

mkdir -p "$TMPDIR" /scratch/gb02/cc6171/logs

# Subset region
LONMIN=100
LONMAX=160
LATMIN=-50
LATMAX=10

process_var() {
    local VAR="$1"
    local TYPE="$2"  # "3D" or "SFC"

    if [[ "$TYPE" == "3D" ]]; then
        BASEDIR="$BASEDIR_3D"
        SUFFIX="pl"
        OUTTYPE="pressure-levels"
    else
        BASEDIR="$BASEDIR_SFC"
        SUFFIX="sfc"
        OUTTYPE="single-levels"
    fi

    local OUTDIR="${OUTBASE}/${OUTTYPE}/reanalysis/${VAR}/1989/10dayav_1980-1989"
    local OUTFILE="${OUTDIR}/${VAR}_era5_oper_${SUFFIX}_19891212.nc"
    mkdir -p "$OUTDIR"

    # Skip if already exists
    if [[ -f "$OUTFILE" ]]; then
        echo "Skipping $VAR ($TYPE)  already done."
        return
    fi

    echo "Processing $TYPE variable $VAR..."

    local TMPFILES=()
    for YEAR in $YEARS; do
        local INFILE="${BASEDIR}/${VAR}/${YEAR}/${VAR}_era5_oper_${SUFFIX}_${YEAR}1101-${YEAR}1130.nc"
        local TMPYEAR="${TMPDIR}/${VAR}_${YEAR}.nc"
        cdo -b F32 sellonlatbox,$LONMIN,$LONMAX,$LATMIN,$LATMAX \
            -seldate,${YEAR}-11-10T00:00:00,${YEAR}-11-19T23:00:00 \
            "$INFILE" "$TMPYEAR"
        TMPFILES+=("$TMPYEAR")
    done

    local MERGED="${TMPDIR}/${VAR}_1980_1989.nc"
    cdo -b F32 mergetime "${TMPFILES[@]}" "$MERGED"

    local DIURNAL="${TMPDIR}/${VAR}_diurnal.nc"
    cdo -b F32 -dhourmean "$MERGED" "$DIURNAL"

    cdo -b F32 settaxis,1989-12-12,00:00,1hour "$DIURNAL" "$OUTFILE"

    echo "Finished $VAR"
}

export -f process_var
export BASEDIR_3D BASEDIR_SFC OUTBASE TMPDIR LONMIN LONMAX LATMIN LATMAX YEARS

run_in_batches() {
    local VARS=("$@")
    local TYPE
    if [[ " ${VARS_3D[*]} " == *" ${VARS[0]} "* ]]; then
        TYPE="3D"
    else
        TYPE="SFC"
    fi

    local BATCH_SIZE=4  # max concurrent jobs
    local i=0
    while [[ $i -lt ${#VARS[@]} ]]; do
        for ((j=0; j<BATCH_SIZE && i<${#VARS[@]}; j++, i++)); do
            process_var "${VARS[$i]}" "$TYPE" &
        done
        wait
    done
}

# Run batches
run_in_batches "${VARS_3D[@]}"
run_in_batches "${VARS_SFC[@]}"

rm -rf "$TMPDIR"

echo "All done."

