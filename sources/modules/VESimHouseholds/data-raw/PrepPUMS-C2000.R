### PUMS File import and header processing

# IMPORTS
library(data.table)
library(tools)

process_2000_pums <- function(PumsFile, GetPumas='ALL') {
  #Read in file and split out household and person tables
  Pums_ <- readLines(PumsFile)
  RecordType_ <- 
  as.vector(sapply(Pums_, function(x) {
    substr(x, 1, 1)
  }))
  H_ <- Pums_[RecordType_ == "H"]
  P_ <- Pums_[RecordType_ == "P"]
  rm(Pums_, RecordType_, PumsFile)

  #Define a function to extract specified PUMS data and put in data frame
  extractFromPums <- 
  function(Pums_, Fields_ls) {
    lapply(Fields_ls, function(x) {
      x$typeFun(unlist(lapply(Pums_, function(y) {
        substr(y, x$Start, x$Stop)
      })))
    })
  }

  #Identify the housing data to extract
  HFields_ls <-
  list(
    SERIALNO = list(Start = 2, Stop = 8, typeFun = as.character),
    PUMA5 = list(Start = 19, Stop = 23, typeFun = as.character),
    HWEIGHT = list(Start = 102, Stop = 105, typeFun = as.numeric),
    UNITTYPE = list(Start = 108, Stop = 108, typeFun = as.numeric),
    PERSONS = list(Start = 106, Stop = 107, typeFun = as.numeric),
    BLDGSZ = list(Start = 115, Stop = 116, typeFun = as.character),
    HINC = list(Start = 251, Stop = 258, typeFun = as.numeric)
  )

  #Extract the housing data and clean up
  H_df <- data.frame(extractFromPums(H_, HFields_ls), stringsAsFactors = FALSE)
  #Extract records for desired PUMAs
  if (GetPumas[1] != "ALL") {
    H_df <- H_df[H_df$PUMA5 %in% GetPumas,]
  }

  #Identify the person data to extract
  PFields_ls <-
  list(
    SERIALNO = list(Start = 2, Stop = 8, typeFun = as.character),
    AGE = list(Start = 25, Stop = 26, typeFun = as.numeric),
    WRKLYR = list(Start = 236, Stop = 236, typeFun = as.character),
    MILITARY = list(Start = 138, Stop = 138, typeFun = as.numeric),
    INCTOT = list(Start = 297, Stop = 303, typeFun = as.numeric)
  )

  #Extract the person data and clean up
  P_df <- data.frame(extractFromPums(P_, PFields_ls), stringsAsFactors = FALSE)
  #If not getting data for entire state, limit person records to be consistent
  if (GetPumas[1] != "ALL") {
    P_df <- P_df[P_df$SERIALNO %in% unique(H_df$SERIALNO),]
  }

  return( list('p' = P_df, 'h' = H_df) )
}

### PUMS data web-scraping

# Downloads and processes legacy 2000 PUMS data 
getDecPUMS <- function(STATE, output_dir = NA) {
  #VARS 
  state_codes <- fread('state.txt') 
  state_codes <- setNames(state_codes$STATE, state_codes$STUSAB) 
  base_url = 'https://www2.census.gov/census_2000/datasets/PUMS/FivePercent' 

  if(length(STATE) > 2 & !is.numeric(STATE)) { 
    STATE <- state.abb[match(toTitleCase(STATE),state.name)] 
  } 
  STATE_NAME <- state.name[match(toupper(STATE),state.abb)] 
  if(!is.numeric(STATE)) STATE_NUM <- state_codes[toupper(STATE)] 
  # Download the PUMS data to tempfile and load directly to data table 
  url <- file.path(
    base_url,
    STATE_NAME, 
    paste0('REVISEDPUMS5_', sprintf("%02d", STATE_NUM), '.TXT')
  )
  temp <- tempfile() 
  download.file(url, temp) 

  # Read .txt to data frames 
  PUMS <- process_2000_pums(temp) 

  # SAVE OUTPUT 
  if(!is.na(output_dir)) { 
    if(!dir.exists(output_dir)) dir.create(output_dir) 
    fwrite(PUMS[['p']], file.path(output_dir, 'pums_persons.csv')) 
    fwrite(PUMS[['h']], file.path(output_dir, 'pums_households.csv')) 
  } else { 
    return(PUMS) 
  } 
} 

