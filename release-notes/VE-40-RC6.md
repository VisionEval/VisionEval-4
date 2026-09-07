This release is principally for improving error handling, but there are a few noteworthy changes:

- Fixed a bug in VETravelDemandMM that led to some wrong estimates for Household DVMT (Issue #11)
- Created a sample model for VE-State that uses the VETravelDemandMM module
- Added an alternate algorithm for PredictWorkers that runs faster than the previous version, but yields slightly different results for the same model due to a different sequence of random numbers. You can enable that by adding "NewWorkerSample: 1" to a mddel stage or scenario. Note that the old version works acceptably fast provided the number of people and workers in each Azone is "reasonable".
- The Snapshot module in the VESnapshot package now successfully does everything it's supposed to (which is make a copy of a field like Household/DVMT to a Datastore variable with a different name, so you can later look at adjustments to that value made in successive module calls). See the documentation below.
- The documentation for updating PUMS and VEPowertrainsAndFuels on the documentation web pages is out of date and will be updated soon. Meanwhile, the code for retrieving PUMS data has been placed in [a new data-raw folder in the VESimHouseholds source tree](https://github.com/VisionEval/VisionEval-4/tree/release/sources/modules/VESimHouseholds/data-raw) and you can play around with either the Census 2000 version or the ACS version for years after 2000.

You can install this release through the [online installer](https://visioneval.github.io/category/download.html). It should work fine to install the new release over your existing code, but as always, we recommend moving VE_RUNTIME to a different folder and ideally using a unique VE_HOME for this release.

Please [post issues](https://github.com/VisionEval/VisionEval-4/issues) if you run into problems.

# PUMS download helper instructions

You should typically select a few PUMAs to format for VisionEval, since it takes a long time to process the data into place if the PUMS file has more than a few tens of thousands of records. To use the functions, just `source('PrepPUMS-ACS.R')` and then run `getACSPUMS(<state>, Year="2024", Get-Pumas=<PUMA-list>)` where `<state>` is a two-digit state code, and `Get-Pumas` is a `c()` list of PUMA identifiers found in the state download for the year. Note that the Year needs to be a character variable, not an integer.

# Snapshot Module

This module illustrates the basic structure of a VE module and implements a useful test facility that can copy an
arbitrary field (or more than one) present in the Datastore into a new field. Useful for grabbing a picture of a field
that is revised at different points in the model stream. Run 'installModel("VESnap")' to install a test module that
illustrates the application of the Snapshot module, including some spiffy features that allow you to take multiple
snapshots of the same field and keep them separate in the Datastore.

## Model Parameter Estimation

This module has no parameters and nothing is estimated.

## How the Module Works

The user specifies fields to copy in their visioneval.cnf script in the Snapshot: block. In the model's run
script, add a series of runModule("Shapshot",...) commands, including the Instance parameter to distinguish
which entry in visioneval.cnf will apply to that Snapshot.

See the VESnap test model that can be installed from this package. When the model runs and the
runModule("Snapshot",...) instruction is encountered, the specified fields are copied into new fields in the
Datastore where they can later be extraced, queried or otherwise used.

## Configuring Snapshot

 The snapshot configuration is placed in the main visioneval.cnf, or within SnapshotDir (system
 parameter) which defaults to "snapshot" and which will be sought in the Model root directory, or
 in the Parameer directory ('defs'). The Snapshot configuration will look like this in its fully
 developed form:

 ```
 Snapshot:
   - Instance: "First"
     Group:        # The Datastore group (shortcut "Year" is acceptable)
     Table:        # The Datastore table within Group
     Name:         # The Datastore field with Table
     SnapshotName: # The name of the field that will be created (in the same Group/Table as the input)
   - Instance: "Second"
     Group:
     Table:
     Name:
     SnapshotName:
     LoopIndex: 1
       # If LoopIndex is missing, snapshot each time through the loop, overwriting to the same place.
       # Otherwise only take the snapshot if the LoopIndex passed to runModule matches this number
 ```

 The Instance is optional. If it is not specified, it will be ignored if it is passed from the
 runModule instruction, and referred to as "NA" (literal character string, not an R NA value). A
 minimal Snapshot will look like the following. Note the dash ahead of 'Group'. Snapshot must
 define a list of objects (that leading dash), even if there is only one Snapshot

 ```
 Snapshot:
   - Group:
     Table:
     Name:
     SnapshotName:
 ```

 Any Group/Table/Name object must already have been specified in an earlier module call in the
 ModelScript (i.e. before the `runModule("Snapshot",...)` step), and it will be looked up in the
 AllSpecs_ls parameter for the properties required to construct a Get or Set specification.

 Finally, you can use Instance and LoopIndex together with this configuration:

 ```
 # In visioneval.cnf:
 Snapshot:
   - Instance:     "FirstLoop"
     Group:        "Year"
     Table:        "Household"
     Name:         "DVMT"
     SnapshotName: "HhDVMTFirstLoop"
     LoopIndex:    1
   - Instance:     "SecondLoop"
     Group:        "Year"
     Table:        "Household"
     Name:         "DVMT"
     SnapshotName: :HhDVMTSecondLoop
     LoopIndex:    2

 # In model run script (run_model.R):
 ... # Earlier script lines
 for (i in 1:2) {
   runModule("Snapshot", "VESnapshot", RunFor = "AllYear", RunYear = Year, Instance="FirstLoop", LoopIndex=i)
   runModule("Snapshot", "VESnapshot", RunFor = "AllYear", RunYear = Year, Instance="SecondLoop", LoopIndex=i)
   ... # Remainder of loop
 }
 ... # Remainder of run script
 ```

 See the VESnap test model, variant snapshot, for a working example.
