/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    High Frequency Checks (run during data collection)

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

	NOTE: This script should typically run SEPARATELY from the main cleaning
	      pipeline, every day during fieldwork.

****************************************************************************/

/*
BEGINNER WORKFLOW DURING DATA COLLECTION:

EVERY MORNING (8:00 AM):
1. Export latest data from SurveyCTO -> $raw/survey_latest.dta
2. Run: do "$hfc/02_hfc.do"
3. Wait 2-3 minutes for checks to complete
4. Review Excel outputs in $hfc_output/
5. Document issues in corrections file
6. Contact field team about flagged problems
7. Repeat tomorrow!

WHY DAILY?
- Problems multiply if not caught early
- Easier to remember context when fresh
- Can retrain enumerators if issues found
- Prevents disaster (=major data quality concerns) at end of data collection
*/

*---------------------------------------------------*
* 2.1 Configure and run HFCs
*---------------------------------------------------*

/* FIRST TIME SETUP (do once):
1. Open: $hfc/hfc_inputs.xlsm in Excel
2. Fill in these sheets (see Quick Start guide for details):
   - versions: Form version tracking
   - ids: ID variables to check for duplicates
   - missing: Critical variables that shouldn't be missing
   - outliers: Variables to check for extreme values
   - constraints: Logic rules data must follow
   - specify: "Other specify" variables to track
   - comments: Comment fields from survey
3. Save and close Excel file
*/

* Import HFC configuration
ipacheckimport using "$hfc/hfc_inputs.xlsm"
	// Loads your settings from Excel

* Run all checks at once (EASIEST METHOD)
ipacheck, ///
	survey([SURVEY_NAME]) ///
	id(unique_id) ///
	enum(enumerator_id) ///
	date(interview_date) ///
	outfile("$hfc_output/hfc_outputs_`current_date'.xlsx")
	// REPLACE bracketed items with your variable names
	// CREATES: One Excel file with all check results


* OR run individual checks (MORE CONTROL, BETTER FOR LEARNING)

** Check 1: Survey form versions
ipacheckversions using "$hfc/hfc_inputs.xlsm", ///
	sheet("versions") ///
	id(unique_id) ///
	enum(enum_id) ///
	outfile("$hfc_output/01_versions_`current_date'.xlsx")
	// FINDS: Enumerators using outdated form versions

** Check 2: Duplicate IDs (MOST CRITICAL!)
ipacheckids using "$hfc/hfc_inputs.xlsm", ///
	sheet("ids") ///
	id(unique_id) ///
	enum(enum_id) ///
	date(interview_date) ///
	outfile("$hfc_output/02_duplicate_ids_`current_date'.xlsx")
	// FINDS: Same ID appearing multiple times
	// CRITICAL: Must resolve before analysis!

** Check 3: Duplicates in other variables
ipacheckdups gps_latitude gps_longitude phone_number, ///
	id(unique_id) ///
	enum(enum_id) ///
	date(interview_date) ///
	outfile("$hfc_output/03_other_dups_`current_date'.xlsx")
	// FINDS: Same GPS/phone across different IDs
	// SUGGESTS: Might be same respondent with different IDs

** Check 4: Missing critical variables
ipacheckmissing using "$hfc/hfc_inputs.xlsm", ///
	sheet("missing") ///
	id(unique_id) ///
	enum(enum_id) ///
	outfile("$hfc_output/04_missing_`current_date'.xlsx")
	// FINDS: Missing values in important variables

** Check 5: Outliers
ipacheckoutliers using "$hfc/hfc_inputs.xlsm", ///
	sheet("outliers") ///
	id(unique_id) ///
	enum(enum_id) ///
	outfile("$hfc_output/05_outliers_`current_date'.xlsx") ///
	sd(3)
	// FINDS: Extreme/impossible values
	// sd(3) = beyond 3 standard deviations

** Check 6: Logic constraints
ipacheckconstraints using "$hfc/hfc_inputs.xlsm", ///
	sheet("constraints") ///
	id(unique_id) ///
	enum(enum_id) ///
	date(interview_date) ///
	outfile("$hfc_output/06_constraints_`current_date'.xlsx")
	// FINDS: Violations of logical rules
	// Example: Age < 18 but survey requires 18+

** Check 7: "Other specify" responses
ipacheckspecify using "$hfc/hfc_inputs.xlsm", ///
	sheet("specify") ///
	id(unique_id) ///
	enum(enum_id) ///
	outfile("$hfc_output/07_other_specify_`current_date'.xlsx")
	// EXTRACTS: All "other" text responses for review

** Check 8: Field comments
ipacheckcomments using "$hfc/hfc_inputs.xlsm", ///
	sheet("comments") ///
	id(unique_id) ///
	enum(enum_id) ///
	outfile("$hfc_output/08_comments_`current_date'.xlsx")
	// EXTRACTS: All enumerator notes/comments

** Check 9: Survey progress
ipatracksurvey using "$hfc/hfc_inputs.xlsm", ///
	id(unique_id) ///
	submit(submissiondate) ///
	outfile("$hfc_output/09_tracking_`current_date'.xlsx")
	// SHOWS: Completion rate, daily progress

** Check 10: Enumerator performance
ipacheckenumdb using "$hfc/hfc_inputs.xlsm", ///
	enum(enum_id) ///
	outfile("$hfc_output/10_enum_dashboard_`current_date'.xlsx")
	// SHOWS: Performance metrics per enumerator

** Check 11: Overall dashboard
ipachecksurveydb using "$hfc/hfc_inputs.xlsm", ///
	outfile("$hfc_output/11_survey_dashboard_`current_date'.xlsx")
	// SHOWS: Overall data quality summary
