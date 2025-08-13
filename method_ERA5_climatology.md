# ERA5 10-Year 10-Day Average Climatology

This script creates a **10-year (2010–2019) climatology** of mid-November 10-day (10–19 Nov) average diurnal cycles for both ERA5 **pressure-level** and **surface** variables.   
It is designed for producing boundary conditions compatible with ACCESS-rAM3, with the **time axis reset to 12 Dec 2019**. This is simply as it was the date of the first test case. 

## Input data
- ERA5 hourly reanalysis from `/g/data/rt52/era5/`
- Pressure-level variables (`u`, `v`, `q`, `t`)
- Surface variables (`ci`, `sd`, `sp`, `stl1–4`, `swvl1–4`, `z`, `lsm`, `skt`, `sst`)

## Output
- Written to `/scratch/gb02/cc6171/era5/.../10dayav_2010-2019/`
- One file per variable, e.g.  
  ```
  /scratch/gb02/cc6171/era5/pressure-levels/reanalysis/u/10dayav2010-2019/.....nc
  ```
- Files contain a **24-hour diurnal cycle** (averaged over 10 to 19 Nov, 2010 to 2019), spatially subset to a region (lon=125–140`, `lat=-15 to -5) substantially larger than the outer domain .

## Running on Gadi
1. **Load the required module:**   Not needed I think as this is in the script.
   ```bash
   module load cdo
   ```

2. **Submit the PBS job:**
   ```bash
   qsub era5_10dayav_20yr.sh
   ```

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
- Adjust years, bounding box, or variable lists inside the script if needed, other scripts in directory exist for 1980s, 1990s, and 2000s.
