### PUMS File import and header processing

# IMPORTS
library(data.table)
library(tools)

# Install PUMS files in inst/extdata in preparation for rebuilding packages

Prepped_PUMS_files <- c(
  p="pums_persons.csv",
  h="pums_households.csv"
)

install_PUMS <- function(extdata="../inst/extdata",pums_files=Prepped_PUMS_files,overwrite=FALSE) {
  if ( ! dir.exists(extdata) ) {
    stop("Directory ",extdata," does not exist")
  }
  if ( ! all(file.exists(pums_files)) ) {
    message("Prepared PUMS files don't exist; please rebuild them")
    stop("Missing PUMS files")
  }
  if ( any(pums_exists<-file.exists(file.path(extdata,pums_files))) && ! overwrite ) {
    message("Existing prepared PUMS files will not be overwritten")
    print(pums_files[pums_exists])
    message("Add 'overwrite=TRUE' to function call and try again, or move the files")
    stop("Won't overwrite existing PUMS files")
  }
  message("Don't forget to rebuild the packages!")
  print(c("VESimHouseholds","VELandUse","VESimLandUse"))
  Prepped_PUMS_files[file.copy(pums_files,extdata,overwrite=overwrite)]
}

# Prepare PUMS files

PUMS_types = c("p","h")

# downloaded_PUMS is a character vector with the form:
# c( p= , h= )
# The elements are the paths of .zip files as downloaded from data.census.gov
# GetPumas is either 'ALL' or a character vector of PUMA5 values found in the
# downloaded Census household file.
# savedir (defaulting to the current directory) could also be e.g. "../inst/extdata"
# to skip the installation step above
prepare_PUMS <- function(downloaded_PUMS,GetPumas='ALL',savedir=".") {
  if ( ! all(names(downloaded_PUMS) %in% PUMS_types) ) {
    stop("Invalid names for downloaded PUMS files")
  }
  processed_pums <- list()
  for ( type in PUMS_types ) {
    message("Processing ",downloaded_PUMS[type]," with type ",type)
    processed_pums[[type]] <- process_acs_pums(downloaded_PUMS[type],type,GetPumas)
    fwrite(processed_pums[[type]], file.path(savedir,Prepped_PUMS_files[type]))
  }
  invisible(processed_pums)
}

# Internal function to process PUMS via temporary unzip file
process_acs_pums <- function(PumsFile, type, GetPumas='ALL') {
  # ACS PUMS to legacy Census PUMS fields
  # Make any modifications here as necessary
  meta = list(
    'h' = list(
      SERIALNO = list(acsname = 'SERIALNO', class ='character'),
      PUMA5 = list(acsname='PUMA', class='character'),
      HWEIGHT = list(acsname='WGTP', class='numeric'),
      UNITTYPE = list(acsname='TYPEHUGQ', class='numeric'),
      # TYPEHUGQ has different codes (1=Housing Unit; 2=Institutionalize; 3=Noninstitutionalized)
      PERSONS = list(acsname='NP', class='numeric'),
      BLDGSZ = list(acsname='BLD', class='character'),
      HINC = list(acsname='HINCP', class='numeric')
    ),
    'p' = list(
      SERIALNO = list(acsname = 'SERIALNO', class ='character'),
      AGE = list(acsname='AGEP', class='numeric'),
      WRKLYR = list(acsname='WKL', class='character'),
      MILITARY = list(acsname='MIL', class='numeric'),
      INCTOT = list(acsname='PINCP', class='numeric')
    )
  )

  colNames <- lapply(meta, function(x) sapply(x, function(y) y[['acsname']]))
  colclass <- lapply(meta, function(x) sapply(unname(x), function(y) {
    setNames(y[['class']], y[['acsname']])
  }))

  # extract .zip file
  cmd <- paste0("unzip -p '", PumsFile, "' '*.csv'")
  df <- fread(cmd = cmd, 
    select = names(colclass[[type]]),
    colClasses = colclass[[type]]
  )
  message("Unzip complete")

  # Rename ACS PUMS fields to match legacy Census PUMS fields
  setnames(df, colNames[[type]], names(colNames[[type]]))

  # Limit PUMS data to GetPumas list
  if ( type=="h" && ( length(GetPumas)>1 || GetPumas[1] != "ALL" ) ) {
    if ( all(GetPumas %in% df$PUMA5) ) {
      df <- df[ df$PUMA5 %in% GetPumas, ]
    } else {
      message("Missing PUMAs requested:")
      print( GetPumas[ ! GetPumas %in% df$PUMA5 ] )
      stop("Missing PUMAs")
    }
  } # person file will include all records and get trimmed later when the VESimHouseholds package is built

  # Fix NA in HINC field to be 0 for CreateEstimationDatasets.R
  if ( "HINC" %in% names(df) && any(is.na(df$HINC)) ) df$HINC[is.na(df$HINC)] <- 0

  # Recode UNITTYPE by subtracting 1
  # PUMS 2000:
  #     0 = Housing unit
  #     1 = Institutional group quarters
  #     2 = Noninstitutional group quarters
  # PUMS ACS:
  #     1 = Housing unit
  #     2 = Institutional group quarters
  #     3 = Noninstitutional group quarters
  if ( "UNITTYPE" %in% names(df) ) df$UNITTYPE <- df$UNITTYPE-1

  return(df)
}

# Downloads files and returns their names
download_PUMS <- function(STATE,YEAR,output_dir=".") {
  base_url = 'https://www2.census.gov/programs-surveys/acs/data/pums'
  PUMS <- lapply(
    PUMS_types, function(f) { 
      url <- file.path(base_url, YEAR, '5-Year', 
        paste0('csv_', f, tolower(STATE), '.zip')) 

      pums_file <- file.path(output_dir, basename(url)) 

      # TODO: Download first, then process separately possibly using
      # previously downloaded data.
      message("Downloading from ",url)
      message("Downloading to   ",pums_file)
      download.file(url, pums_file)
      # Check download success
      # Check download timeout
      pums_file # return name of file downloaded
    }
  )
  names(PUMS) <- PUMS_types
  return(PUMS) # check that it's a valid set of existing files
}

# STATE is 2-character census state code
# YEAR is a valid base year for 5-year PUMS
# output_dir is where to put the downloaded files
# save_dir is where to put the processed files
# GetPumas is a list of PUMA5 values consistent with the STATE/YEAR download
getACSPUMS <- function(STATE,YEAR,output_dir=".",save_dir=output_dir,GetPumas="ALL") {
  # Download - can skip if files matchiing STATE, YEAR already exist or force re-download
  pums_files <- download_PUMS(STATE,YEAR,output_dir)
  # Prepare - processes the two file names
  results <- prepare_PUMS(pums_files,GetPumas,output_dir)
  # result is a list of two data frames of prepared PUMS data (also saved if needed)
  # need to report if they're not being saved
  invisible(results)
}

# Downloads and processes post-2000 PUMS
# STATE must be 2-digit state code from census geography
# getACSPUMS <- function(STATE, YEAR='2024', GetPumas='ALL', output_dir=".", save_zip = T) { 
#   base_url = 'https://www2.census.gov/programs-surveys/acs/data/pums'
#   PUMS <- lapply(
#     c('p', 'h'), function(f) { 
#       url <- file.path(base_url, YEAR, '5-Year', 
#         paste0('csv_', f, tolower(STATE), '.zip')) 
# 
#       if(save_zip == F) { 
#         temp <- tempfile() 
#       } else {
#         temp <- file.path(output_dir, basename(url)) 
#       }
# 
#       # TODO: Download first, then process separately possibly using
#       # previously downloaded data.
#       message("Downloading from ",url)
#       message("Downloading to   ",temp)
#       download.file(url, temp)
#       message("Processing ACS type ",f)
#       df <- process_acs_pums(temp, type=f, GetPumas)
#       message("Done Processing ACS type ",f)
# 
#       return(df) 
#     }
#   ) 
#   names(PUMS) <- c('p', 'h') 
# 
#   # SAVE OUTPUT 
#   if (!is.na(output_dir)) {
#     message("Saving output...")
#     if (!dir.exists(output_dir)) dir.create(output_dir)
#     message("PUMS persons")
#     fwrite(PUMS[['p']], file.path(output_dir, 'pums_persons.csv'))
#     message("PUMS households")
#     fwrite(PUMS[['h']], file.path(output_dir, 'pums_households.csv'))
#   } else {
#     return(PUMS) 
#   }
# }

