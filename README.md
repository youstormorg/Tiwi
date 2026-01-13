# Tiwi Island thunderstorm simulations
Greetings fellow ACCESS-rAM3er! This github is in very early stages but the end goal will be to fully explain our Tiwi Island thunderstorm simulations run under modified ERA5 initial and boundary conditions. This type of setup could be used for other experiments where the initial data needs to be modified.
A brief overview of the method - we modify the ERA5 initial and boundary conditions creating new ERA5 files that have identical formatting and place them in a new "fake" ERA5 directory tree. 
We copy over some of the ACCESS-rAM3 python scripts and redirect where they access the ERA5 files so that they read in our new files. Some other modifications are needed and will be documented here.
So long as this is done correctly and the date and time of your ERA5 modified files match those you have set in ACCESS-rAM3, this should work however issues and potential instabilities due to ingesting modified data are possible.

If you are new to ACCESS-rAM3 then the first thing to do is to run through the standard Lismore flood tutorial case.

Tiwi Islands ACCESS 
This repository contains information about the Tiwi Islands thunderstorm configuration. It is being maintained by Chris Chambers (cchambers@unimelb.edu.au)

#Key links

ACCESS-rAM3 getting started:
https://docs.access-hive.org.au/models/run-a-model/run-access-ram/

UM Chemistry page for details on adding variables using the rose GUI: https://www.ukca.ac.uk/wiki/index.php/UKCA_Chemistry_and_Aerosol_vn11.8_Tutorial_10


Mat Lipson et al. github on the Sydney 1 km domain, it is this setup that was the base domain setup that we have used: 
https://github.com/21centuryweather/RNS_Sydney_1km

# Where is the data?

The output from the simulations has approved storage on gdata ACCESS-NRI project gx60 so you will have to request membership for that project.
There are two sets of 11 simulations that use 5 year climatological November conditions 1970-1974  ..... 2020 to 2024 as the initial, and boundary conditions.
The two sets differ in the 3D climatological data only.

The first set uses 3D 5-year climatological data for all four of the 3D variables; u, v, q, t. This set is stored in:

/g/data/gx60/experiments/2025-11-19_Tiwi_12h_1970-1974/19851101T0000Z

IMPORTANT! The 2025-11-19_Tiwi_12h_1970-1974 part of the directory name does not need to be changed for different periods, it is just the name set when the storage was approved.

The second set uses 5-year climatological data for q and t, while u and v are set to zero. This set is stored in:

/g/data/gx60/experiments/2025-06-11_tiwi/20001101T0000Z

# Setup ACCESS-rAM3 to read your modified ERA5 files

As of December 2025 these are just rough notes on this process and the directories are those that I used. 
This method was used in the middle of 2025 using the first full release of ACCESS-rAM3 so there may be potential changes that have occured since - adapt accordingly ;) 
Thanks to Paul Gregory for helping out and Chermelle Engel for her python scripts and advice.

What we are doing here is creating copies of some ACCESS-rAM3 scripts so that we can modify them to change the directory where they access the ERA5 directories.

* Create a new directory that will contain the nci_era5grib_parralel python scripts

mkdir era5grib_parallel
*	So this is now going to be my nci_era5grib_parralel directory:
/home/563/cc6171/era5grib_parallel
*	It is OK to keep in my home directory as it is just scripts so not large.
*	Now copy Chermelle’s nci_era5grib_parralel python scripts to this directory.

cd era5grib_parallel

cp /g/data/vk83/apps/conda/access-ram/2025.03.0/lib/python3.11/site-packages/era5grib_parallel/cdo_era5grib.py ./

cp /g/data/vk83/apps/conda/access-ram/2025.03.0/lib/python3.11/site-packages/era5grib_parallel/nci_era5grib_parallel.py ./
 
*	Now change the ERA5 directory so that it now uses your modified "fake" ERA5 directories.

vi cdo_era5grib.py

ERADIR = "/scratch/gb02/cc6171/era5"
*	Creating your own fake ERA5 directories.
*	make sure you keep the same subdirectory structure as used for the original ERA5 data on NCI. This is because the python scripts access and define these sub directories. These could be changed in the scripts at a later date but for the moment, and probably forever I’m keeping as is.

* and then change the command in the app/nci_era5grib_parallel/rose-app.conf to point to the location of your modified python script.

* Next step is to create your fake ERA5 directories, change to your fake ERA5 directories.

cd /g/data/gb02/cc6171/
*	make your new base era5 directory - should move this off scratch.
*	there are a lot of era5 directories to be created, it is better to write a script that creates the directories - chatGPT can help, I will look for the script I used.

mkdir era5

cd era5
*	ERA5 directories, create these directory structures for all the variables both 3D and 2D used as input to ACCESS-rAM3:

era5/single-levels/reanalysis/......

era5/pressure-levels/reanalysis/.....

* here is a list of all the ERA5 variables that ACCESS-rAM3 uses as input:

        "skt, single, 235",
        "sp, single, 134",
        "ci, single, 31",
        "sst, single, 34",
        "sd, single, 141",
        "stl1, single, 139",
        "stl2, single, 170",
        "stl3, single, 183",
        "stl4, single, 236",
        "swvl1, single, 39",
        "swvl2, single, 40",
        "swvl3, single, 41",
        "swvl4, single, 42",
        "u, pressure, 131",
        "v, pressure, 132",
        "t, pressure, 130",
        "q, pressure, 133",
        "lsm, single, 172",
        "z, single, 129"]

Once all this is done you can modify ERA5 data and place them in your new directories.

# Domain setup
![Alt text](figs/Tiwi_domains.png "Optional Title")

# Creating the ERA5 decadal mid November climatologies
see method_ERA5_climatology.md
Our updated method uses the ERA5 monthly averaged by hour data that is available on NCI.
Our earlier method focussed on a mid-November environment and involved taking out the 10 to 19 Nov ERA5 data over a large Australia covering region for a decade, for example 2010 to 2019 and then averaging across all these mid-November days (100 in total) to create a 24 hour climatology hourly 1 day dataset representative of the pre-monsoon in that decade.
see method_ERA5_climatology.md

# Early tests

![Alt text](figs/QCL_QCF_key.png)

12 December 2016 vs 12 Dec 2016 with zero wind applied to the initial and boundary conditions.

https://github.com/user-attachments/assets/5a4778a0-930a-4998-8eab-33fe083d127c

