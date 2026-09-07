# Rebuilding VESimHouseholds to use local PUMS data

The 'data-raw' folder contains R scripts for retrieving and formatting
# Updating Public Use Microdata Samples (PUMS) data

PUMS data are used in VisionEval's integrated populationg synthesizer.
The standard module is built using PUMS data from Oregon from year
2000. In general, it is recommended that the package be rebuilt with
more recent PUMS data for the area being modeled.

The basic steps for updating the PUMS data include:

1. Determine the Public Use Microdata Areas (PUMAs) that you would
   like to include in the VESimHouseholds package. The codes should match
   the `PUMA5` field in the raw PUMS data from the US census.

2. Determine what year of PUMS data you would like to retrieve. The
   script will load data from the ACS 5-year Estimates.

3. Start R and load the `PrepPUMS-ACS.R` script from this folder

4. Run the `getACSPUMS` function to retrieve the desired raw PUMS data
   and generate the two required build files: `pums_households.csv`
   and `pums_persons.csv`

5. Move or copy the two build files to the package's adjacent
   `inst/extdata` folder. You may want to rename the default
   `pums*.csv` files first.

6. Rebuild the VESimLandUse package

## Detailed instructions for updating PUMS data

1. Identify the state and PUMAs you would like to include.

   You will need a 2-digit state code (standard US abbreviations) and
   a list of PUMA5 identifiers. The PUMA geography used for recent ACS
   data is from Census 2020. You can investigate the PUMAs starting
   here:[https://www.census.gov/programs-surveys/geography/guidance/geo-areas/pumas.html]
   (https://www.census.gov/programs-surveys/geography/guidance/geo-areas/pumas.html)

2. Select the ACS data year you would like to retrieve

   The year should be 2020 or later, and it should correspond to the
   BaseYear (or before) for your VisionEval model.

3. Start R and load the `PrepPUMS-ACS.R` script from this folder.

   Start R and set its working directory to the folder in the package
   source code containing this `Readme.md` file and the
   `PrepPUMS-ACS.R` script. To load the file, run this R command:
   
   ```
   source("PrepPUMS-ACS.R")
   ```

4. Run the `getACSPUMS()` function with suitable arguments

   The function takes three key arguments. There are two others that
   you can typically ignore; investigate the `.R` file if you are
   curious.

   STATE
   : Two-digit state abbreviation (e.g. `"VA"` or `"MN"`)

   YEAR
   : Character string for the desired year (e.g. `"2024`)

   GetPumas
   : A character vector of the PUMAs you would like to include in
     the build files. All PUMAs will be downloaded for the state, and
     this subset will be used to filter down the results by comparing
     elements of this vector with the PUMA5 field in the downloaded
     data. The default (`"ALL"`) will leave all the PUMAs for the
     state in the build files. If you're in a large state, you might
     want to limit the build files to reduced set of representative
     PUMAs, but there is no intrinsic limit on the size of the build
     files, so this parameter is technically optional. The goal is to
     incorporate a suitable range of household and person data for
     your area.

   Once this retrieval function has run, you will have two `.csv`
   files in the folder (the "build files"): `pums_households.csv` and
   `pums_persons.csv`.

5. Move or copy the build files to the `VESimHousholds/inst/extdata`
   folder

   For reference, the folder containing this Readme file and the PUMS
   retrieval script is `VESimHouseholds/data-raw`, so you're just
   moving the build files "next door".

   You may want to rename or move the default build files first, but
   there's no harm in overwriting them. You also have the option of
   giving the `VESimHouseholds` package an alternate name reflecting
   the revised raw PUMS data (e.g. `VESimHousholdsRVA` if I were, for
   instance, rebuilding PUMS for the Richmond Virginia area. Remember
   that in addition to changing the package folder name, you also need
   to edit the Name field in the package's `DESCRIPTION` file prior to
   rebuilding.

6. Rebuild the `VESimHouseholds` package

   Here's the complete set of steps for the rebuild:

   1. Install the most current VisionEval release from Github (e.g.
      using the oneline installation script from [the VisionEval
      website](https://visioneval.github.io/category/download.html)

   2. Edit the `ve-build-config.yml` file in the VE_RUNTIME or VE_HOME
      folder. The builder will look in the runtime first, then the
      home folder. There is a sample `ve-build-config-default.yml`
      file includes locations to rebuild all of VisionEval, which you
      can certainly do if you have installed the source code for the
      full system. Or you can edit the `PackageSources` section
      of the file to just includ the path to the folder containing
      your update to `VESimHouseholds`.

   3. To do the build from a runtime (no other source code)
      installation, do these steps in the R console after you have
      edited `ve-build-config.yml` and started VisionEval:

      ```
      require(VEBuild)
      ve.build()
      ```

      The updated package will be placed in your VisionEval R library
      and will be used when you next run your model.


