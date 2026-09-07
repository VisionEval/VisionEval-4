This release of VisionEval 4.0 mostly focuses on getting the installer to work better, plus improving the documentation (see the README.md for installation and building instructions).

## Installer

See the README.md file.

## Spatial geo.csv

I've also added support for spatial geo.csv files, using the sf:st_read function to read .csv files (appears to work) as well as any spatial formation. If you want to access a spatial file, you'll need to add a GeoFile definition to your visioneval.cnf. If it's a file-based spatial format, just put the name of the main file (e.g. myModelGeo.shp) as the value of GeoFile, like this:

```
GeoFile: MyModelGeo.shp
```

It will look in the ParamDir (by default `defs` within your model folder). It will NOT use an absolute path - you would need to change ParamDir, but of course that will affect units.csv and deflators.csv as well.  The default GeoFile will continue to be "geo.csv".

If you want to use a geodatabase in a format supported by the R sf package (e.g. PostGIS), add a GeoFile entry to your visioneval.cnf file structured like this:

```
GeoFile:
  - <Spatial Database Reference> # see help("sf:st_read")
  - <Spatial Layer>
```
Currently, you need fields in the GeoFile named explicitly "Marea", "Azone" and "Bzone" (and it might complain about "Czone"). I will be finishing an implementation in the next round allowing you to map one or more of those to fields with other names (e.g. mapping Bzone onto BlockGroup). The file needs to include geographies at the smallest level (either Azone or Bzone) and it will not automatically merge them if, for example, you spatial file is at the census Block level but you're hoping to use Block Group aggregates for the Bzones. I might relax that once we get the field mapping in place, though for transparency it will be better if you pre-merge the geographics in your GIS. The next implementation will also allow you to select which extra fields from your GeoFile to include in your Datastore results - currently, all the extra fields present in GeoFile will be added to the smallest geography Datastore outputs, including the "geography" spatial field (see the `sf::st_read` documentation for its format). Note that the GeoFile metadata is not currently saved in the Datastore anywhere, but the use case is just to join the Datastore results as tables back to GeoFile so that shouldn't be a problem.

## PreviousYear Specification Group

The PreviousYear feature is a brand new beta feature that almost everyone can safely ignore. The PreviousYear group is used in a new module Get specification (like the existing "Year" or "BaseYear"). It will look in visioneval.cnf for a vector of years called (duh) PreviousYear, like this:

```
PreviousYear:
  - 2010  # if this is the BaseYear
  - 2020
  - 2030
  - 2040
```
That would be useful for 10 year increments heading (say) to 2050. You will need to define Model Stages for those previous years and make sure they run in an appropriate order. When you get to running (say) RunYear 2030, a specification in GROUP PreviousYear will find the value from the 2020 Group (previous year) in the Datastore.

If you don't define PreviousYear, the lookup will use the model "Years" parameter, but that will only work if all the years for your model are included in a single stage (which is a huge waste of runtime resources if you're also doing scenarios - though it would simplify testing for small models).

I expect to be working with the team that requested the PreviousYear feature (Brian G and Liming W.) to develop test models and samples showing how to configure the model runs. The feature will eventually be used to implement incremental land use forecasting in VisionEval across multiple years.

As always, please post an issue here if you're having trouble getting some or all of this to work.
