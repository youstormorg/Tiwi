# ERA5 20-Year 10-Day Average Climatology

This script creates a **20-year (2000–2019) climatology** of mid-November 10-day (10–19 Nov) average diurnal cycles for both ERA5 **pressure-level** and **surface** variables.  
It is designed for producing boundary conditions compatible with ACCESS-rAM3, with the **time axis reset to 12 Dec 2016**.

## Input data
- ERA5 hourly reanalysis from `/g/data/rt52/era5/`
- Pressure-level variables (`u`, `v`, `q`, `t`)
- Surface variables (`ci`, `sd`, `sp`, `stl1–4`, `swvl1–4`, `z`, `lsm`, `skt`, `sst`)

## Output
- Written to `/scratch/gb02/cc6171/era5/.../10dayav20yr/`
- One file per variable, e.g.  
  ```
  /scratch/gb02/cc6171/era5/pressure-levels/reanalysis/u/10dayav20yr/u_10dayav20yr.nc
  ```
- Files contain a **24-hour diurnal cycle** (averaged over 2000–2019), spatially subset to the Tiwi Islands region.

## Running on Gadi
1. **Load the required module:**
   ```bash
   module load cdo
   ```

2. **Submit the PBS job:**
   ```bash
   qsub era5_10dayav_20yr.sh
   ```

3. **PBS job settings:**
   - Queue: `normal`
   - Walltime: `12:00:00`
   - Memory: `64GB`
   - Temporary jobfs: `100GB`
   - 1 CPU (processing is sequential to avoid I/O contention)

4. **Output check:**
   Monitor job progress with:
   ```bash
   qstat -u $USER
   ```
   and verify the logs in:
   ```bash
   /scratch/gb02/cc6171/era5/logs/
   ```

## Notes
- The script processes each variable independently to avoid memory spikes.
- Spatial subset is set to `lon=125–140`, `lat=-15 to -5` (Tiwi Islands region).
- Adjust years, bounding box, or variable lists inside the script if needed.
