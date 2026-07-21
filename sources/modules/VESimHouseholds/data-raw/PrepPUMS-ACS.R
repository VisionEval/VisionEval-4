### PUMS File import and header processing

# IMPORTS
library(data.table)
library(tools)

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
  df <- fread(cmd = paste0("unzip -p '", PumsFile, "' *.csv"), 
    select = names(colclass[[type]]),
    colClasses = colclass[[type]])

  # Rename ACS PUMS fields to match legacy Census PUMS fields
  setnames(df, colNames[[type]], names(colNames[[type]]))

  # Fix NA in HINC field to be 0 since CreateEstimationDatasets.R
  # rejects NA values.
  if ( "HINC" in names(df) && any(is.na(df$HINC)) ) df$HINC[is.na(df$HINC)] <- 0

  return(df)
}

# Downloads and processes post-2000 PUMS
# STATE must be 2-digit state code from census geography
getACSPUMS <- function(STATE, YEAR='2024', GetPumas='ALL', output_dir=".", save_zip = T) { 
  base_url = 'https://www2.census.gov/programs-surveys/acs/data/pums'
  PUMS <- lapply(
    c('p', 'h'), function(f) { 
      url <- file.path(base_url, YEAR, '5-Year', 
        paste0('csv_', f, tolower(STATE), '.zip')) 

      if(save_zip == F) { 
        temp <- tempfile() 
      } else {
        temp <- file.path(output_dir, basename(url)) 
      }

      message("Downloading from ",url)
      message("Downloading to   ",temp)
      download.file(url, temp)
      message("Processing ACS type ",f)
      df <- process_acs_pums(temp, type=f, GetPumas)
      message("Done Processing ACS type ",f)

      return(df) 
    }
  ) 
  names(PUMS) <- c('p', 'h') 

  # SAVE OUTPUT 
  if (!is.na(output_dir)) {
    message("Saving output...")
    if (!dir.exists(output_dir)) dir.create(output_dir)
    message("PUMS persons")
    fwrite(PUMS[['p']], file.path(output_dir, 'pums_persons.csv'))
    message("PUMS households")
    fwrite(PUMS[['h']], file.path(output_dir, 'pums_households.csv'))
  } else {
    return(PUMS) 
  }
}
