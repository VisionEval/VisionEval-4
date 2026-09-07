This release provides the first publication of VisionEval 4, with a new installation scheme that should be a lot easier and more modular. The guts of VisionEval is the same as the most recent VisionEval 3 release in VisionEval-dev. All that has changed so far in Version 4 is the installation and build process. More documentation will be forthcoming in June 2025.

To install VisionEval, you can clone the repository, start R in the repository root (so it sources "VE-Bootstrap.R") and then run ve.build().

More simply, you can use the online installer (which also gives you a full build option from a snapshot rather than a git clone). To get started:

1. Pick a supported version of R (any of the R 4.4.x or R 4.5.x releases will work)
2. Make sure you have installed [R Tools for Windows](https://cran.r-project.org/bin/windows/Rtools/) for your version of R
3. Start your version of R either from R GUI or from RStudio
4. Set its working directory to some empty directory (e.g. C:\Documents\VisionEval)

Then run the installer script either from this Github or the website.

Here's the link for this Github:

``` R
source(ve.url<-"https://github.com/VisionEval/VisionEval-4/blob/release/sources/framework/VEStart/inst/download/VE4-install.R")
```
Here's the link from the website:

``` R
source(ve.url<-"https://visioneval.github.io/assets/install/VE4-install.R")
```
