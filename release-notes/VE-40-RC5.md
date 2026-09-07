# Release Notes for January 26, 2026

As always, if you have problems using (or understanding) any of the
new features in this release, please [submit an issue](https://github.com/VisionEval/VisionEval-4/issues).
We'll work promptly either to fix the problem or to provide a
workaround. Fixed problems will be available in new commits on the
`development` branch, and will be rolled into the next overall
release. We'll post comments in the Issues section when the issue is
resolved.

Here is a list of the major changes in this release. There were also a few message
adjustments, including error checking on some of the inputs to make it easier to
figure out why things are not working in a new model.

-   Numerous updates to the build system and the installer, notably:

    -   Eliminated the packaged source option for building an installer - it's
        easier and less confusing to just use `ve.build()` on a source code
        snapshot or git clone. The installer now presents three options:

        -   Install from a binary release, which has two variants, one just
            containing the VisionEval packages (and downloading the remaining
            dependencies online as the installer runs), and the other containing
            the VisionEval packages along with all the dependencies as a
            pre-installed Windows library. The second type of installer is
            overall a bit faster to install; the first will get the latest R
            dependency packages as part of the installation.

        -   Install from a release snapshot, which gets you a copy of the GitHub
            repository as of the release. The snapshot does not include any
            later modifications to the development environment that have not yet
            been packaged into a release. Because this installation also uses
            the `VE-Bootstrap.R` development environment, you will need RTools
            and the build will take an hour or so depending on how fast your
            machine is.

        -   Install from a local clone, which you would use if you have
            separately cloned the GitHub repository. Using this option is
            functionally identical to just setting the R working directory to
            your repository root and loading `VE-Bootstrap.R`. You'll still need
            to perform the build operation.

    -   Added several functions to the build environment that will help navigate
        the build process.

        -   `ve.setup()` to set interactively (via a TclTk dialog) the VE_BUILD
            and VE_RUNTIME folders (it is recommended to keep these separate
            from the GitHub root - the defaults will work fine if just doing
            add-ons to your binary VisionEval installation

        -   `ve.locations()` to report the current environment settings
            (defaults or values that override defaults, which can be set via
            ve.setup(), or manually in .Renviron, or globally through User
            Environment variables

        -   `ve.instructions()` to re-issue the list of build functions (which
            varies depending on how much is already built)

    -   The build environment is loaded in one of two ways:

        -   From `VE-Bootstrap.R` if you are starting from the git repository
            (either by cloning or using the snapshot option from the installer),
            or

        -   From the `VEBuild` package if you want to build an additional or
            altered package into your existing VisionEval installation. You can
            load the build environment by using `library(VEBuild)` once you have
            a working VisionEval installation (even a binary one).

-   There is now a "Manifest" constructed when VisionEval packages are built
    that describes when and how the package was built.

    -   The manifest adds fields to the package's `DESCRIPTION` that report
        information about the build date, specific git commit, branch and
        repository used for the package. If the package code did not come from a
        Git repository, the manifest fields will say so and tell you the folder
        that was used.

    -   You can access the Manifest information using the standard R
        `packageDescription()` function, finding something like the following:

        -   In the next release, the manifest information will be gathered for each
            package used in the model run. It should be pretty straightforward to
            write a short R script to interrogate each VisionEval package's
            DESCRIPTION to assemble the version information after doing a model run.
            If you do write such a script, please create a GitHub issue and we'll
            use that code to develop the model run functionality.

```
> packageDescription("VEStart")
Type: Package
Package: VEStart
Title: Bootstrap VisionEval with online load
...
VEBranch: development
VEBuildDate: Wed Jan 21 15:04:33 2026
VECommit: 2c8a3806d6ca659b3c243a8b3718fd62c1002b02
VELocalRepoPath: N:/Git-Repos/VisionEval-40/
VERemoteURL: git@github.com:visioneval/VisionEval-4.git
VEUpstreamBranch: visioneval/development
```

-   The walkthrough was comprehensively revisited and checked for currency.

    -   You can activate the walkthrough using the `ve.walkthrough()` function
        once you are running VisionEval. "Running" means you either started from
        an installed runtime or home directory, or used the `ve.run()` function
        from within the build environment once the build is complete

    -   The walkthrough creates a separate sub-directory to hold the walkthrough
        results, so any models you install or run will be separate from your
        "real" models. You should be careful not to install real models in the
        walkthrough environment.

    -   You can leave the walkthrough environment and return to your regular
        runtime by using the `exit.walkthrough()` function.

    -   Note that the walkthrough does *not* run functions for you. It just sets
        up an environment that you can explore by opening one of the walkthrough
        scripts (they'll pop up in a File Explorer window) and trying out the
        instructions listed there - there are explanations for the functions
        inline in the walkthrough script files.

-   Exported units now work differently than before. The export should by
    default produce much more intuitive results in exported output files. No
    more speeds exported as "Miles/Day"!

    -   The way this works is that a new field called ModuleUnits is added to
        the attributes of each column of data in the Datastore.

    -   The ModuleUnits are the the units used the module that first created the
        Datastore column.

    -   By default when extracting or exporting data, the Datastore contents
        will be converted to ModuleUnits.

    -   You can change that behavior by setting `convertUnits=FALSE` when you
        run the export function - you'll then get the unmodified Datastore
        units.

    -   As noted in the walkthrough, you can also force specific conversions by
        creating a file called `display_units.csv` in your` defs` directory
        (next to` geo.csv`). The display units override both the ModuleUnits and
        the Datastore Units unless you choose not to convert units. You can also
        put display_units.csv in the root of your VisionEval runtime and have it
        apply to all your models, but with the new ModuleUnits you don't need to
        do any of that.

    -   To take advantage of ModuleUnits, you will need to re-run your models
        since the older outputs did not include ModuleUnit information.

-   The "Initialize" module can now have a full name that includes its package,
    rather than always being called "Initialize", which has proved very
    confusing when debugging models.

    -   A number of packages have included a special "Initialize" module that
        manages things like optional input files, file consistency checking, and
        even a bit of model estimation.

    -   The initialization process has been changed so the "Initialize" module
        can now be called "Initialize\<VEPackage\>". The standard packages that
        include an Initialize function now have had those module names
        comprehensively changed.

    -   If you have variants of standard packages that still have an
        "Initialize" function, you can continue to build and run those without
        renaming the function (i.e. the new architecture is fully backward
        compatible).

-   The method for reading geo.csv has been changed so you can now use any
    spatial file format with tabular attributes (in addition to .csv files,
    which will still work.

    -   That means specifically that shapefiles will work fine

    -   You can also set up geodatabases (e.g. with PostGis) or any other format
        recognized by the R `sf` package <https://r-spatial.github.io/sf/>.

    -   Any extra fields (but not the spatial geometry) will also be added as Bzone
        tags (or AZone in VE-Stage) in the Datastore to any table that has entries
        for Bzones (or Azone in VE-State) and you can use those to filter and
        aggregate model results using the query mechanism.

    -   Several `visioneval.cnf` settings need to be changed to use an alternate
        format.

        -   `GeoFile: <filename>` should mention the filename with its extension
            (e.g. `mygeo.shp`). The file should be located in the \`defs\`
            directory of your model.

        -   If you are using a geodatabase, look at the documentation for the
            `sf` package to find the right format for the database driver and
            the table that you will use within the database. The
            `visioneval.cnf` entry for GeoFile then has 2 entries:

```
GeoFile:
  - <Driver-and-Database-Name>
  - <Spatial Layer>
```

-   By default, VisionEval expects to find fields in the geography file named
    Marea, Azone, Bzone and perhaps Czone (which is ignored). You can map names
    in the shapefile to Azone, Bzone, Czone and Marea (Note: Czones are still
    unused and you don't need to specify anything for that column).

    -   The shapefile must still have exactly one feature per Bzone (or Azone,
        the smallest geography, in VE-State), and the Bzones must be tagged with
        Azone and Marea. The Azone is defined as the area you get were all the
        Bzones to be merged into a single feature using the Azone tag. Likewise
        Mareas.

    -   To obtain Azones, Bzones and Mareas, you can either rename fields in
        your spatial file, or let VisionEval rename them for you. To specify the
        renaming, add a section called \`GeoFileFields\` to your
        \`visioneval.cnf\` that explains which field in the file should
        be used for which of the required VisionEval geography fields:

```
GeoFileFields:
  MPO_Name          : Marea
  Census_County     : Azone
  Census_Block_Group: Bzone
```

-   There is now a special Group called "PreviousYear" available for data
    specifications in new modules.

    - Any field with a PreviousYear Group in its Get specification
      will be retrieved from the Datastore for the PreviousYear
      (rather than the current Year or the BaseYear). That will allow
      modules to build current year estimates incrementally using
      results from previous year runs.

    - You need to set up the PreviousYears in the top (overall model)
      section of your visioneval.cnf if your model runs any years in
      separate model stages (something we highly recommend, rather
      than running all the years in a single model stage, since it
      greatly reduces the model's running time, especially when you
      add new scenarios or make changes to scenario input data).

      - Your model visioneval.cnf should include a `PreviousYears`
        element which has a list of years to be searched as previous
        years. The most recent `Year` group in the Datastore prior to
        the current RunYear that matches one of the PreviousYear
        groups will be used.

      - If no PreviousYears are defined, VisionEval will search the
        required Years element and pick the one before the current RunYear
        (or generate NA if this is the first RunYear). That will only work
        however if all your years are running in the same model stage
        (which we don't recommend as it leads to painfully slow runtimes
        in models with many years or scenarios).

      - Naturally it is your responsibility to make sure that a suitable
        PreviousYear is available, and also that the model can handle
        the NA's that are generated if there is no suitable PreviousYear
        (as would be the case, say, for the BaseYear).

      - The PreviousYears Group has not been thoroughly tested. Please report
        problems via the [GitHub issues tab](https://github.com/VisionEval/VisionEval-4/issues)
