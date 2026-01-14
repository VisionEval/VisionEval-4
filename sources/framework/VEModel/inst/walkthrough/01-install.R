### 01-install.R
#   Walk through model installation

# Load VEModel package (in effect, the visioneval environment)
require(VEModel)

##########################
# CREATE MODEL ENVIRONMENT
##########################

# Eliminate everything other than possible pre-existing VERSPM-run
message("Model environment ",
  if ( ! dir.exists("models") ) {
    dir.create("models")
    "created."
  } else "exists."
)

# Here's how to install and run a model in a script
# See below for some details on opening and investigating a model
# interactively.
message("Pre-running model (Base VERSPM)")
model.path <- "VERSPM-run"
if ( ! dir.exists(file.path("models",model.path)) ) {
  message("Installing VERSPM ('base' variant) as ",model.path)
  vr <- installModel("VERSPM",modelPath=model.path,variant="base",confirm=FALSE)
} else {
  message("Using existing ",model.path)
  vr <- openModel(model.path)
}
message("Making sure model '",model.path,"' has been run...")
vr$run() # default "continue" will not re-run model if already "Run Complete"
print(vr)

#######################################
# DEMO INSTALLING OTHER STANDARD MODELS
#######################################

# install models
# Show available models (VERSPM, VE-State, VERPAT, etc.)
installModel()

# Show avaialble variants for one of the models
# Providing an empty string for the variant requests a list of available ones
# This instruction will show variants of VERSPM
installModel("VERSPM",var="") # "var" is short for "variant" - you can spell it out

# Find out what models you already have insalled
dir("models") # Installed and ran base variant of VERSPM as "VERSPM-run" earlier

# Install the base variant as "VERSPM" (with a confirm dialog)
# If you install with no variant listed (as opposed to variant="") it will install the default

message("Type 'y' and hit Enter when prompted")
installModel("VERSPM") # default if running interactively is to ask for a "y" to confirm installation
# If no variant is specified, you get "base", so this instruction creates "VERSPM-base"

dir("models")
# Note that the installed name includes the variant: VERSPM-base and VERSPM-run

# Install some additional models (Enter "y" plus "Enter" when prompted)
# Multi-stage version as "VERSPM-pop" (same model as VERSPM-run above but organized differently)
pop <- installModel("VERSPM",variant="pop",confirm=FALSE)
state <- installModel("VE-State",confirm=FALSE) # if variant is not provided, use "base"

# See what we've got
message('\nExpect to see: "VE-State-Base", "VERSPM-base", "VERSPM-pop" and "VERSPM-run"')
openModel()

# Installed these models:
# Once a model is loaded you can 'print' it to get information about it
message("\nVERSPM-pop:")
print(pop)
message("\nVE-State-base:")
print(state)
rm(pop,state)

# If you install a model again under the same name, it will add a number to it
installModel("VERSPM",confirm=FALSE) # base model again
message('\nExpect to see:')
print(c("VE-State-base", "VERSPM-base", "VERSPM-base(1)", "VERSPM-pop", "VERSPM-run"))
print(dir("models"))
print(openModel())

# And you can get rid of the extra model like this (careful that you're deleting the right one!)
# It's probably better to use File explorer (Windows) or Finder (Mac)
unlink("models/VERSPM-base(1)",recursive=TRUE)

# opening models (e.g. in a new R session, after they are installed)
# you can always re-open a model - it just creates a new R object for manipulating it
vrb <- openModel("VERSPM-base")
print(vrb) # Initialized

model.with.results <- openModel("VERSPM-run")
print(model.with.results)  # Run Complete (has results from being run above, or in an earlier session)

# Please proceed to walkthrough/02-running.R to learn about running models