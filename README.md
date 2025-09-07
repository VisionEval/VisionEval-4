# VisionEval

VisionEval is a model system and supporting software framework for building collaborative disaggregate strategic
planning models. These models can support scenario planning and a variety of "what-if" analyses.

**NOTE ON WEBSITE**:
The VisionEval website can be found at
[https://VisionEval.github.io](https://VisionEval.github.io)

There are basic instructions on the website for installing VisionEval from recent releases. We are moving to a new
installation process which greatly simplifies the installation. Details of that installation framework are presented below.

The new installation and current version of VisionEval is presently fvound in the [VisionEval-4 repository on
Github](https://github.com/VisionEval/VisionEval-4). See the repository details below, especially if you planning
to do development work on VisionEval.

The `development` branch of this repository (VisionEval-4) will be the basis for development of new features
and fixes to VisionEval. To use it, fork this repository, work on a branch departing from `development` and lodge a pull request when you think your work is ready for review.
Be sure to pull the `development` branch into your new branch before placing the pull request - we'll reject the request if it's not making changes to the HEAD of `development`.

The older VisionEval repositories should be considered obsolete (and will gradually be marked as such).

If you have questions, please contact info at visioneval.org. If you think you found a bug, please create an issue explaining in as much detail as possible what you were trying to do (including files or code to reproduce the issue), what happened when you were trying to do it, and why you think what happened is an error (that is, tell us what you think SHOULD have happened).

## Documentation

Documentation for the VisionEval models is online at
[https://visioneval.github.io/docs](https://visionveal.github.io/docs)

That documentation is gradually being updated to reflect the VisionEval-4 installer. It remains current for running VisionEval models, but instructions for building and rebuilding packages are somewhat obsolete. The information on installing and building below should enable you to build updated packages (including updating PUMS or PowertrainsAndFuels fleet tables).

## Release Installation

You can retrieve the current binary release of VisionEval by running the installation script as described here (and on the website).

Start your selected version of R (using the built-in RGui or RStudio, either will work), then copy the following line into your
R console:

```R
source(ve.url<-"https://visioneval.github.io/assets/install/VE4-install.R")
```
Currently, VisionEval will run on any R version in the 4.4.x or 4.5.x series.

**GORY DETAIL** The most up-to-date installer scripts can be found within the Github source tree in `sources/framework/VEStart/inst/download`, or within the `download` folder of the installed VEStart package, which you can locate with the R command `system.file("download",package="VEStart")`

**ADDITIONAL GORY DETAIL** The mysterious `ve.url<-` incantation enables some tcltk dialogs (in file `VE4-UI-tcltk.R`) that give you flexibility in using
releases other than the most current, or in downloading a snapshot of the full VisionEval code without using Git so you
can build the entire system locally. If you leave it out, you'll get a forced installation of the latest
binary release. Note that you still want to do a Git clone from VisionEval-4 development branch
if you are planning to contribute your developments back to the main project.

When the installation is complete, VisionEval will automatically start with your selected runtime
directory as the R working directory. Apart from the installation, using VisionEval 4 will still work for any VisionEval 3 model. The tiny number of new features are all backward compatible.

## Detailed Installation Instructions

The `ve.url<-` method for calling the installation script gives you a variety of choices for
installation.

**1. Set VE_HOME** The first question in the full installation is where you want to put VE_HOME (location for the VisionEval
code library). Use the "Change VE_HOME" button to open a directory finder dialog. You will have the option to
create a new folder if you like. All the stuff you will download for the installation as well as your future
installed VisionEval code will end up in subdirectories of VE_HOME.

**GORY DETAIL** You can have VisionEval for multiple R versions in
the same VE_HOME (but you can only have one VisionEval version per R version). To update VisionEval for a new R version,
just start your new R and run the install script, pointing it at your existing VE_HOME. If you are updating VisionEval
itself to a later release (with or without updating R), we recommend creating a new VE_HOME just to avoid screwy version
problems if you accidentally run your model with an earlier R version.

**GORY DETAIL** If you have an existing VE installation, it is probably safe to point the
installer's VE_HOME location to your existing VisionEval directory. However, if you have a `models` folder there with
precious information in it, you would do well to back that information up now. In fact, you should back it up as soon
as you have finished reading this sentence and before you read or do anything else! It is a known fact that our subjective
reality can affect the timespace continuum such just thinking about new R or VisionEval version can break your existing model.

**2. What kind of installation?** The script will then ask what kind of installation you want to do. There are three choices:

1. Pre-built release (Recommended).
   Like it says, this is what you should do to get the most recent tested and packaged version. If for some reason the
   latest release comes out broken, you can retreat to earlier releases. The script will identify the R version that is
   running and pick installers compatible with that R version (see below).
1. Build from release code.
   This method will let you download the full code snapshot of the release
   you select and launch the VE-Bootstrap.R script that loads the build environment. You can then
   build the entire VisionEval core system from scratch. You will need to have [RTools](https://cran.r-project.org/bin/windows/Rtools/) installed.
   Use this option if you would like to build adjust some of the module
   packages that need updated PUMS or powertrains and fuels information. You do not need to install or know anything about Git
   to use this option. It gets a snapshot of the code and you can copy, modify it, and rebuild it to your heart's content.
   **Do NOT use this option if you expect to contribute your changes back to the VisionEval project. Instead...**
3. Build from Local Clone: This method expects you to already have made a "clone" of the
   VisionEval-4 repository and it will ask you for the directory where you made that clone. It will
   then launch VE-Bootstrap.R to load the build environment. To make that clone, you'll need Git,
   you may want to fork the Visioneval-4 repository, and you'll need to clone either the original
   VisionEval-4 or your fork. Make a fork if you expect to send us pull requests.

Once you have picked your installation type, you'll get a follow-up dialog that lets you pick the repository, with VisionEval-4 as the only
option initially. You can add your own Git repository
using the "Add Repositories" button - but it won't show up until you have created tagged releases with assets built using the `ve.make.installer` function.
The release name doesn't matter, but the asset files must have specific names for them to be recognized by the installer.

The installer will automatically select the newest valid release (i.e. one that seems to have installers attached to it with their specific names).

The dialog will let you pick which type of installer you want - they all have the same stuff in them, they just use different R mechanisms for getting the
VisionEval code on your computer. The fastest installer (smallest and easiest) is the one called **"VE-Installer-Windows"** and that will automatically be selected
if there is one available for your version of R. That installer will need to go online to download the 150 or so R dependency packages that VisionEval requries.

Alternatively, you can dowload the larger **"VE-Installer-Library"** which works like the VisionEval-3 installer: it downloads an immense zip file with all the VisionEval
packages plus all its dependencies and just unzips that into the `ve-lib` directory that contains all the packages. A binary release may not be available if you're running an R version that was released within the last couple of weeks. In that case, you can build from the release code, or make a local clone and build from that. Explanations for how to build are below.

Finally, you can try **"VE-Installer-Source"**. You can't use this installer unless you have [RTools](https://cran.r-project.org/bin/windows/Rtools/) installed on Windows. This installer is intended for Macintosh or Linux. But to use it on one of those operating systems, you'll need to do tedious iterations of building all the
VisionEval packages and all the many dependency packages. Each build iteration will crash, asking you to install yet another operating system package. If you keep at
it relentlessly (build - crash - install missing OS package) you will eventually end up with a working VisionEval. We are working on automating the SystemRequirements, which will eventually make installing on Macintosh or Linux as easy as a Windows installation (though it will require system administrator rights, which the Windows installation does not). [The `pak` package](https://pak.r-lib.org) which will provide the necessary services).

**GORY DETAIL** The "source" installer does **NOT** install editable source - use the "Build from Release Code" or "Build from Local Clone" installation methods if you want to do that. This "source" installer installs R source packages (as opposed to R binary packages), which are very different from anything resembling what we usually think of as "source code".

**IMPORTANT BUILD INFORMATION** If you're doing any kind of building from the source installer (or from clones or snapshots of VisionEval-4), you
will need first to install [RTools for your version of R](https://cran.r-project.org/bin/windows/Rtools/).

**BUILDING ON MACINTOSH OR LINUX** On Linux or Macintosh, you'll need to ensure you have a development version of R installed, along
with the operation system "devtools" package (including C++ and Fortan compilers and related tools).
Be aware that building and running VisionEval requires a lot of RAM (a minimum of 8 Gigabytes is
recommended). If you're using a Linux cloud server, you'll need something quite a bit more capacious
(and expensive) than what is usually delivered at the "low end". Having multiple CPUs will not speed
up the build process, but when you run models, you can use additional processes to run multiple
model scenarios in parallel. But remember: 8 Gigabytes of RAM will still be needed for each scenario you're running
simultaneously.

## Issues

Please submit issues, bugs, or feature requests about VisionEval on the
[VisionEval-Dev issues page](https://github.com/VisionEval/VisionEval-4/issues). 

[VisionEval.org issues page](https://github.com/VisionEval/VisionEval.org/issues).

## For Developers: Building 

To modify and rebuild the released VisionEval system, you can clone a suitable branch
(either "main" or "development") from the "development" repository:
[VisionEval-Dev repository](https://github.com/VisionEval/VisionEval-dev). 

Here are the build steps:

1. Clone the Github
   You will also need [RTools](https://cran.r-project.org/bin/windows/Rtools/) if you are building on
   Windows. Currently, it is possible to build from source on Mac or Linux, but you will need to load
   all the SystemRequirements into your operating system. That can be annoying and tedious. We will fix
   that soon so the SytemRequirements can be auto-installed (if you have administrator/sudo permissions)
   or at least give you an installation instruction (so your authorized administrator can install them).
   Keep an eye out for future releases in June 2025.
2. Start `VisionEval-dev.Rproj` in the root directory, or you can use launch.bat. To use `launch.bat`,
   you will need to set the R_HOME system or user environment variable. Open the R you want to use
   and run `R.home()` to get the directory you need. The build will work with any recent R version
   (ideally in the 4.3 or 4.4 series of R releases).
3. Run ve.build() to construct the packages
4. Run ve.run() to launch the runtime (note that the built "runtime" is only used indirectly)
    1. VisionEval runs in the new "runtime.test" directory
    2. You can set a directory of your choice selected either by passing it as a parameter
       (`ve.run('myRuntimeDirectory")`) or by setting the VE_RUNTIME environment variable either
       as a system or user environment variable, or by defining it in the `.Renviron` file that
       is created in the repository root when you run `ve.build()`.
       A complete working runtime will be created in VE_RUNTIME if it does not already exist
5. Once running, do `walkthrough()` (with no parameters) to get a list of
   sample scripts illustrating basic functions (all to run in an additional temporary runtime to
   avoid confusing them with real work).
    1. `walkthrough()` is also available for ordinary users in the distributed runtime
    3. The walkthrough function creates a temporary runtime directory (to avoid trampling any real models you
       may have). Run `exit.walkthrough()` (or quit and restart the R session) to return to regular VE_RUNTIME

## For Developers: Submitting changes or bug requests

If you intend to submit changes back to the VisionEval project, please clone the [VisionEval-Dev
repository, `development` branch](https://github.com/VisionEval/VisionEval-Dev/tree/development).
Pull requests against this branch are welcome (but make sure you have rebased the pull request on
the current HEAD of `development`).

Pre-built binary installers of recently released versions (the "main" branch) are available at
[https://visioneval.org](https://visioneval.org) and as "releases" in the `development` branch of
`VisionEval-dev`.

You can install the directly from a copy (.zip) or clone of this VisionEval repository branch, using
the instructions in the `build/Building.md` file in the repository, or in the detailed installation
instructions at [https://visioneval.github.io/docs](https://visioneval.github.io/docs)

You do *NOT* need to fork the repository unless you are planning to submit changes (pull requests)
back to the VisionEval project.
