# Set up and run VisionEval

# Find possible source code bootstrap startup file
# Change VE_HOME by editing .Renviron or run ve.setup() once VE is running.
# VE_ROOT is set by VE installer (it will be the root of the git source, which
# might have been downloaded by the installer or separately cloned)
# VE_HOME is the place where we'll build ve-lib.
ve.home <- Sys.getenv("VE_HOME",getwd())
ve.root <- Sys.getenv("VE_ROOT",file.path(ve.home,"build-source"))

# Load ve-lib if it exists
this.R <- paste(c(R.version["major"],R.version["minor"]),collapse=".")
ve.lib <- file.path(ve.home,"ve-lib",tools::file_path_sans_ext(this.R))
.libPaths(ve.lib) # Won't add it if it doesn't exist; used to find VEStart below

bootstrap.files <- unique(
  file.path(
    c(
      ve.home,
      ve.root
    ),
    "VE-Bootstrap.R"
  )
)
bootstrap.files <- bootstrap.files[file.exists(bootstrap.files)]
if ( length(bootstrap.files) > 0 ) {
  # Start from a source code bootstrap; changing ve.sources to the source tree
  Sys.setenv(VE_SOURCE=(file.path(ve.root,"sources")))
  source(bootstrap.files[1])
} else {
  # Otherwise, do a runtime start (VEStart must be somewhere in .libPaths())
  # If this fails, VE is not installed yet
  require(VEStart,quietly=TRUE )
  startVisionEval()
}
