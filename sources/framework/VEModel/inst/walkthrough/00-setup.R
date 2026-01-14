### 00-setup.R
#   Set up the walkthrough environment
#   It's harmless to run this again, but generally you should just use "ve.walkthrough()"
#   TODO: In dev environment, no parameters on ve.test() will load the walkthrough
#   In runtime enviroment, "ve.walkthrough()" will do the same (in walkthrough's own runtime)

setup.walkthrough <- function(walkthrough.reset=FALSE) {  # Wrapping in "local" will leave no new names in the user's environment
  # First part is redundant with standard developer or runtime setup
  # It will support starting the walkthrough from an arbitrary directory if VE is nearby
  # This script presumes we're working in the directory that contains the walkthrough scripts

  checkVE <- function(lib.loc=NULL) {
    # VE is already located?
    return(all( c("visioneval","VEModel") %in% installed.packages(lib.loc=lib.loc)[,"Package"]))
  }

  # Set up .libPaths with locally-discovered (or pre-existing) ve-lib
  vePresent <- function() {
    if ( checkVE() ) return(TRUE)
    # No obvious VE installation - look around nearby for "ve-lib"
    for ( wd in c(getwd(),dirname(getwd()),dirname(dirname(getwd()))) ) {
      message("Checking ",wd)
      lib.loc <- file.path(wd,"ve-lib")
      if ( checkVE(lib.loc) ) {
        .libPaths( c( lib.loc, .libPaths() ) )
        return(TRUE)
      }
    }
    # Failed to find ve-lib
    return(FALSE)
  }
  if ( ! vePresent() ) stop("Cannot locate ve.lib - are you working in your VE runtime?")

  # Access the runtime environment for variables like ve.runtime
  env.loc <- if ( ! "ve.env" %in% search() ) {
    attach(NULL,name="ve.env")
  } else {
    as.environment("ve.env")
  }

  # Create (or find) a walkthrough runtime directory within the working directory
  # which is VE_RUNTIME if you used the ve.walkthrough() function to start
  if ( exists("orig.runtime",envir=env.loc,inherits=FALSE) ) setwd(get("orig.runtime",envir=env.loc))
  message("Setting up walkthrough in ",getwd())
  walkthrough.action <- "Using"
  walkthroughRuntime <- grep("runtime.*",list.dirs(),value=TRUE)[1]
  if ( walkthrough.reset ) {
    retry.loop <- 1
    while ( dir.exists(walkthroughRuntime) && retry.loop < 4) {
      unlink(walkthroughRuntime,recursive=TRUE)
      walkthroughRuntime <- grep("runtime.*",list.dirs(),value=TRUE)[1]
      retry.loop <- retry.loop + 1
    }
  }
  # extra backstop here to prevent nesting walkthrough runtimes if we re-run
  # ve.walkthrough from within a walkthrough environment.
  if ( ! dir.exists(walkthroughRuntime) ) {
    walkthroughRuntime <- normalizePath(tempfile(pattern="runtime",tmpdir="."),winslash="/",mustWork=FALSE)
    dir.create(walkthroughRuntime)
    walkthrough.action <- "Created"
  } else {
    walkthroughRuntime <- normalizePath(walkthroughRuntime,winslash="/",mustWork=TRUE)
  }

  # stash the existing ve.runtime, if any
  if ( exists("ve.runtime",envir=env.loc,inherits=FALSE) ) {
    if ( ! exists("orig.runtime",envir=env.loc) ) {
      env.loc$orig.runtime <- env.loc$ve.runtime
    }
  }
  env.loc$ve.runtime <- walkthroughRuntime

  # add function to restore runtime after starting walkthrough
  env.loc$exit.walkthrough <- function() {
    if ( exists("orig.runtime",envir=env.loc,inherits=FALSE) ) {
      env.loc$ve.runtime <- env.loc$orig.runtime
      rm("orig.runtime",envir=env.loc)
    }
    setwd(env.loc$ve.runtime)
    invisible(getwd())
  }

  # Run in walkthrough runtime
  setwd(walkthroughRuntime)
  message(walkthrough.action," walkthrough runtime directory:\n",getwd())

  # Make sure there is a "Models" directory in the walkthrough runtime folder
  modelRoot <- file.path(
    walkthroughRuntime,
    visioneval::getRunParameter("ModelRoot") # Uses runtime configuration or default value "models"
  )
  if ( ! dir.exists(modelRoot) ) dir.create(modelRoot,recursive=TRUE,showWarnings=FALSE)
  message("Do exit.walkthrough() or quit R to exit walkthrough environment")
}
