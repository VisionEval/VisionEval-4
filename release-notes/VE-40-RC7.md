# VisionEval Release of September, 2026

The following updates are included in this release:

1. Updates to code and support scripts for localizing PUMS data used in the `VESimHouseholds` population
   synthesis package. See the instructions in `sources/modules/VESimHouseholds/data-raw/Readme.md`.

2. Updated the builder code so the build customization file `ve-build-config.yml` can be placed either
   in `VE_HOME` (which is unnatural given the typical work flow) or in `VE_RUNTIME`. `VE_RUNTIME` makes more
   sense since that's where the sample build configuration file is placed, and that's where the builder
   will look first.

3. Increased the valid range of tabular data used to evaluate congested lane miles in the
   `CalculateRoadPerformance` module of the `VETravelPerformance` Package. This solves a bug
   which would lead to failed estimates of congested DVMT when available lane miles exceeded
   a certain threshold.

4. Incorporated fixes suggested by various contributors culminating in pull-request #15 that should
   fully repair a longstanding problem in the optional VETravelDemandMM module. The problem was that the
   household DVMT prediction split the modeling into urban and non-urban segments. The ordering by household
   ID was disrupted by doing the prediction in two segments, which were then not in the same order as the
   original household file, leading to mismatches when the results were reattached. A preliminary fix that
   worked for the basic sample models was offered in the previous release (VE-40-RC6). Limitations to that
   approach were identified in models with more complex zone naming schemes, and those are now fixed through
   the hard work of @maxclements032 (see the pull request summary below).

5. Added debugging information logging and forced garbage collection to the `AssignVehicleOwnership` module
   of `VEHouseholdVehicles`. That function was using excessive RAM (in excess of 22Gb) when running extremely
   large models. The fix attempts to release memory more frequently than R does by default, and testing shows
   that VisionEval can now run a VE-State model of the SCAG (LA/Southern California) MPO successfully on
   systems with 32Gb RAM.

## Pull Request Summary fixing alignment problem in optional package VETravelDemandMM

### Summary

Issue #11 correctly identified that predictions generated within
segments sometimes need to be restored to the source household order.
Commit `8dbec0184b11dad36789a755aeb5810203ddddaf` implemented that
restoration by extracting numeric substrings from `HhId`.

That approach does not generalize to multi-Azone or numeric-Azone
models. With numeric Azones, an ID such as `51001-1` produces two
numeric values instead of one; in the Virginia case that exposed the
problem, 13,842 household rows produced 27,684 ordering values. With
nonnumeric Azones, household-number suffixes repeat across Azones and
therefore are not unique ordering keys.

This change treats household IDs as complete identifiers and restores
prediction order by matching full IDs to the source dataset. It also
verifies that the mapping is complete and one-to-one before reordering
and fails explicitly when it is not.

Single-Azone RVMPO-style IDs retain their existing behavior, and `merge_preds = FALSE` is unchanged.

### Testing

- Added focused regression coverage for numeric-Azone IDs, nonnumeric multi-Azone IDs with repeated suffixes, RVMPO-style IDs, `merge_preds = FALSE`, and invalid ID mappings.
- Passed the exact 13,842-row reproduction of the Virginia failure and the retained 15-case full-`HhId` regression suite.
- Passed VisionEval-native package build/install and `R CMD check` with no errors.
- Previous RVMPO-MM regression testing found identical prediction ordering and zero prediction delta.
- External SayedMM, WPPDC, and PlanRVA runs completed successfully with the full-ID correction.

