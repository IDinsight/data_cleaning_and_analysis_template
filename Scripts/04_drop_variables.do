/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Drop irrelevant variables

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

****************************************************************************/

*---------------------------------------------------*
* 4.1 Drop process/metadata variables
*
* CONCEPT: Survey tools add many "behind the scenes" variables
* EXAMPLES: deviceid, username, starttime, caseid
* WHY DROP: Not needed for analysis, clutters dataset
*---------------------------------------------------*

drop deviceid devicephonenum subscriberid simid ///
     username caseid duration formdef_version ///
     starttime endtime submissiondate ///
     sensor_* audio_audit*
	// deviceid = which tablet/phone was used (not needed)
	// username = enumerator login (not needed)
	// duration = survey length (keep if analyzing quality)
	// sensor_* = all variables starting with "sensor_"
	// audio_audit* = all variables starting with "audio_audit"
	//
	// * = wildcard (matches anything)
	// Example: sensor_* matches sensor_1, sensor_activity, etc.

* Verify variables are gone
describe device*
	// Should show: "no variables defined"
	// If variables still there, check spelling


*---------------------------------------------------*
* 4.2 Drop variables that are completely empty
*
* CONCEPT: Sometimes all values are missing (.)
* REASONS: Question never asked, skip logic broken, etc.
* ACTION: Drop automatically
*---------------------------------------------------*

missings dropvars, force
	// Finds: Variables where ALL values are missing
	// Drops: These variables automatically
	// force = don't ask confirmation for each one
	//
	// OUTPUT: Shows which variables were dropped
	// REVIEW: Make sure nothing important was dropped!


*---------------------------------------------------*
* 4.3 Drop test/practice observations
*
* CONCEPT: Enumerators practice during training
* PROBLEM: These aren't real surveys
* SOLUTION: Drop based on date or test flag
*---------------------------------------------------*

* Method 1: Drop by date (before official start)
gen date_submitted = dofc(submissiondate)
	// Converts SurveyCTO datetime to Stata date
format date_submitted %td
	// Makes date readable (not internal number)

drop if date_submitted < d(01jan2025)
	// Drops all surveys before January 1, 2025
	// CUSTOMIZE: Use your actual survey start date
	// Format: d(DDmmmYYYY)
	// Examples: d(15mar2025), d(01apr2024)

drop date_submitted
	// Clean up temporary variable

* Method 2: Drop flagged test cases (if you have test flag)
drop if test_case == 1
	// If your survey marks tests with test_case = 1

count
	// Check remaining sample size
