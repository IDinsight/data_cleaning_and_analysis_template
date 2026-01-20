/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Complete data cleaning workflow for [SURVEY NAME]
	
	Input:          Raw data from SurveyCTO/CommCare/ODK
	Output:         Cleaned dataset without PII, ready for analysis
	
	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]
	Reviewed by:    [REVIEWER NAME]
	Review date:    [DATE]
	
	NOTES FOR BEGINNERS:
	- Read ALL comments before running any code
	- Replace ALL [PLACEHOLDERS] with your actual values
	- Run section by section (not all at once)
	- Check results after each section
	- Save frequently!
	
	NOTES FOR ADVANCED USERS:
	- Uses iefieldkit and ipacheck for maximum efficiency
	- Integrates gtools for large dataset optimization
	- Excel-based workflows for team collaboration
	- Fully reproducible and documented

****************************************************************************/

/*______________________________________________________________________________


TABLE OF CONTENTS

	0. ENVIRONMENT SETUP (5 minutes)
		0.1 Install required packages (one-time)
		0.2 Initialize environment
		0.3 Set file paths
		0.4 Start logging
	
	1. DATA IMPORT AND INSPECTION (5 minutes)
		1.1 Load raw data
		1.2 Basic inspection
		1.3 Keep completed surveys only
	
	2. HIGH FREQUENCY CHECKS - DURING DATA COLLECTION (Daily, 15 min)
		2.1 Run comprehensive quality checks
		2.2 Review outputs and document corrections
	
	3. CORRECTIONS AND DUPLICATES (30 minutes)
		3.1 Apply corrections from Excel
		3.2 Resolve duplicates systematically
		3.3 Merge half-complete surveys (if applicable)
	
	4. DROP IRRELEVANT VARIABLES (10 minutes)
		4.1 Drop process/metadata variables
		4.2 Drop empty variables
		4.3 Drop test observations
	
	5. VARIABLE CLEANING (45 minutes)
		5.1 Convert special missing values
		5.2 Extract multiple response variables
		5.3 Destring variables
		5.4 Clean string variables
		5.5 Recode "Other (specify)" responses
		5.6 Standardize units and formats
	
	6. DATA VALIDATION AND QUALITY CHECKS (30 minutes)
		6.1 Check outliers
		6.2 Check constraints and logic
		6.3 Check missing patterns
		6.4 Verify computed variables
	
	7. CREATE AND TRANSFORM VARIABLES (45 minutes)
		7.1 Create unique identifiers
		7.2 Recode categorical variables
		7.3 Create dummy variables
		7.4 Create indices and scores
		7.5 Create analysis-ready variables
	
	8. METADATA: LABELS AND DOCUMENTATION (30 minutes)
		8.1 Export codebook template (iecodebook)
		8.2 Apply labels from codebook
		8.3 Add notes to variables
		8.4 Document skip patterns
	
	9. DE-IDENTIFICATION AND DATA PROTECTION (20 minutes)
		9.1 Separate PII data
		9.2 Remove/mask PII from main dataset
		9.3 Verify de-identification complete
	
	10. ORDER, SORT, AND SAVE (10 minutes)
		10.1 Order variables logically
		10.2 Sort dataset
		10.3 Compress dataset
		10.4 Save cleaned dataset
	
	11. CLOSE LOG (2 minutes)

TOTAL TIME: 
- First time: 4-6 hours (includes learning)
- After setup: 2-3 hours
- With automation: 30-60 minutes

_____________________________________________________________________________*/


/****************************************************************************
	0. ENVIRONMENT SETUP
	
	PURPOSE: Prepare Stata and create organized file structure
	TIME: 5 minutes
****************************************************************************/

/*===========================================================================
	0.1 Clear Stata's memory and set preferences
===========================================================================*/

clear all
	// Removes any data currently in Stata's memory
	// ALWAYS start do files with this
	// Prevents conflicts with previous work

clear matrix
	// Clears mathematical matrices (advanced feature)
	
clear mata
	// Clears Mata programming environment (advanced)
	
macro drop _all
	// Deletes all saved shortcuts (globals/locals)
	// Ensures clean start
	
set more off
	// Tells Stata: "Don't pause when output fills screen"
	// Makes code run continuously without manual intervention
	
set maxvar 30000
	// Allows up to 30,000 variables (default is less)
	// Needed for surveys with many variables
	
version 18.0
	// Locks code behavior to Stata 18.0
	// Ensures code works same way in future
	// REPLACE: Use your Stata version (type "version" to check)


/*===========================================================================
	0.2 Install required packages (ONE-TIME SETUP)
	
	INSTRUCTIONS:
	1. Remove the /* and */ on first run
	2. Wait for installation to complete
	3. Add /* and */ back to comment out
	4. Never need to run again (unless updating)
===========================================================================*/

/*
*---------------------------------------------------*
* Core efficiency packages (REQUIRED)
*---------------------------------------------------*

* IPA High Frequency Checks - Daily quality monitoring
net install ipacheck, all replace ///
	from("https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master")

* World Bank iefieldkit - Codebook-based cleaning
ssc install iefieldkit

* Update ipacheck to latest version
ipacheck update


*---------------------------------------------------*
* Speed optimization packages (For large datasets >100k obs)
*---------------------------------------------------*

* gtools - 60-95% faster operations
ssc install gtools

* ftools - Alternative speed package
ssc install ftools


*---------------------------------------------------*
* Utility packages (RECOMMENDED)
*---------------------------------------------------*

* Missing value analysis
ssc install missings

* Label management
ssc install labutil2

* Outlier handling
ssc install winsor2

* Uniqueness checks
ssc install unique
ssc install distinct


*---------------------------------------------------*
* Verify installations
*---------------------------------------------------*

which ipacheck
which iecodebook
which gtools
which missings

di "✓ All packages installed successfully!"

*/


/*===========================================================================
	0.3 Set up file paths
	
	CONCEPT: Create shortcuts so you don't have to type full paths
	BENEFIT: Code works on any computer
	
	ACTION NEEDED: Replace [PROJECT_FOLDER] with your actual folder name!
===========================================================================*/

* Create date stamp for file naming
local current_date : di %tdCY-N-D daily("$S_DATE", "DMY")
	// Creates: 2025-01-15 (or whatever today's date is)
	// Used for: Versioning output files
	// Example: cleaning_2025-01-15.log

* Detect user and operating system
local user = c(username)
	// Gets: Your computer username
	
local os = c(os)
	// Gets: "Windows" or "MacOSX"

* Set main project directory
if "`os'" == "MacOSX" {
	global db "/Users/`user'/IDinsight Dropbox/[PROJECT_FOLDER]"
		// Mac format
		// REPLACE [PROJECT_FOLDER] with your folder name!
		// Example: "Education_RCT_Kenya_2025"
}
else {
	global db "C:/Users/`user'/IDinsight Dropbox/[PROJECT_FOLDER]"
		// Windows format
		// REPLACE [PROJECT_FOLDER] with your folder name!
}

* Navigate to project folder
cd "$db"
	// All file operations now happen in this folder

* Create shortcuts for subfolders //NOTE: Keep same across all project files as globals are stored across .do files
		global raw          "$db/01_Data/01_Raw"              // Original data (never modify!)
		global clean        "$db/01_Data/02_Clean"            // Cleaned datasets
		global clean_pii    "$db/01_Data/02_Clean/PII"        // Data with personal info
		global clean_nopii  "$db/01_Data/02_Clean/Non-PII"    // Data without personal info
		global corrections  "$db/02_Corrections"              // Correction Excel files
		global cleaning     "$db/03_Do_Files/Cleaning"        // Cleaning scripts
		global hfc          "$db/03_Do_Files/HFC"             // HFC scripts
		global hfc_output   "$db/04_HFC_Outputs"              // Daily check results
		global logs         "$db/05_Logs"                     // Log files
		global sample       "$db/06_Sample"                   // Sampling frames
		global output       "$db/07_Output"                   // Final outputs


/*===========================================================================
	0.4 Start logging
	
	PURPOSE: Record everything Stata does
	BENEFIT: Complete audit trail of your work
===========================================================================*/

capture log close
	// Close any existing log (prevents errors)
	
log using "$logs/cleaning_`current_date'", replace
	// Start new log file with today's date
	// Everything from now on is recorded!


/****************************************************************************
	1. DATA IMPORT AND INSPECTION
	
	PURPOSE: Load data and understand its structure
	TIME: 5 minutes
****************************************************************************/

/*===========================================================================
	1.1 Load raw data
===========================================================================*/

use "$raw/[DATASET_NAME]_raw.dta", clear
	// REPLACE [DATASET_NAME] with your actual filename
	// Example: use "$raw/household_survey_raw.dta", clear
	//
	// "clear" = remove any existing data from memory first
	// REQUIRED: Or you'll get "data in memory" error

/* ALTERNATIVE: If you have CSV file
import delimited "$raw/[DATASET_NAME]_raw.csv", clear
	// CSV = Comma Separated Values (from Excel, Google Sheets, etc.)
	// Stata converts CSV to its internal format
*/


/*===========================================================================
	1.2 Basic inspection - ALWAYS do this first!
	
	GOAL: Understand what you're working with before changing anything
===========================================================================*/

describe
	// Lists all variables with their types and labels
	// LOOK FOR:
	//   - Total number of variables
	//   - Which are string (str) vs numeric (byte, int, float)
	//   - Which variables have labels
	
codebook, compact
	// Shows summary of each variable
	// LOOK FOR:
	//   - How many unique values (too many? too few?)
	//   - How many missing values
	//   - Value ranges (any obvious errors?)
	
count
	// Shows total number of observations (surveys)
	// CHECK: Is this close to expected sample size?
	
browse in 1/20
	// Opens data viewer showing first 20 rows
	// LOOK FOR:
	//   - Do values make sense?
	//   - Any obvious errors?
	//   - Variables with strange values?
	// CAUTION: NEVER edit data in browse window! Use code instead.


/*===========================================================================
	1.3 Check survey completion and filter
===========================================================================*/

* First, understand completion rates
tab survey_status, missing
	// Shows breakdown of survey statuses
	// Example output:
	//   Complete: 2,345 (87%)
	//   Incomplete: 198 (7%)
	//   Refused: 132 (5%)
	
tab consent_yn, missing
	// Verify consent was properly recorded
	// All should be 1 (yes) for analysis

* Keep only completed, consented surveys
keep if consent_yn == 1 & survey_status == 1
	// Drops: Incomplete, refused, non-consented surveys
	// CUSTOMIZE: Adjust codes based on your survey
	//   - Check codebook for what 1 means in your data
	//   - Might be survey_status == "Complete" (text) instead
	
count
	// Verify final sample size
	// Example: Started with 2,676, now have 2,345
	// Lost: 331 surveys (12.4%)
	// CHECK: Is this acceptable? Document in report.


/****************************************************************************
	2. HIGH FREQUENCY CHECKS (DURING DATA COLLECTION)
	
	PURPOSE: Run quality checks daily while data is being collected
	TIME: 15 minutes per day
	BENEFIT: Catch and fix errors early (saves hours later!)
	
	NOTE: This section should typically be in a SEPARATE do file
	      that runs every day during fieldwork
****************************************************************************/

	/*
	BEGINNER WORKFLOW DURING DATA COLLECTION:
	
	EVERY MORNING (8:00 AM):
	1. Export latest data from SurveyCTO → $raw/survey_latest.dta
	2. Run: do "$hfc/3_hfc.do"
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


/****************************************************************************
	3. CORRECTIONS AND DUPLICATES
	
	PURPOSE: Fix identified errors and resolve duplicates
	TIME: 30 minutes
****************************************************************************/

	*---------------------------------------------------*
	* 3.1 Apply corrections from Excel (MOST EFFICIENT!)
	*
	* WORKFLOW:
	* 1. Review HFC outputs (Section 2)
	* 2. Document corrections in Excel file
	* 3. Run this command to apply all corrections
	*---------------------------------------------------*
	
	* Set correction file location
	global corrections_file "$corrections/corrections_`current_date'.xlsx"
		// Your Excel file with corrections
		
	global uid_variable "key"
		// REPLACE "key" with your ID variable name
		// Common names: key, unique_id, hhid, respondent_id
	
	* Apply ALL corrections with one command
	ipacheckcorrections using "$corrections_file", ///
		sheet("corrections") ///
		id($uid_variable) ///
		logfile("$logs/corrections_log_`current_date'.xlsx")
		// READS: Excel file with corrections
		// APPLIES: Each correction automatically
		// LOGS: All changes made
		//
		// EXCEL STRUCTURE NEEDED:
		// Column A: id (e.g., HH_001, HH_002)
		// Column B: variable (e.g., age, income)
		// Column C: old_value (e.g., 350, 100000000)
		// Column D: new_value (e.g., 35, 100000)
		// Column E: comment (e.g., "Typo, extra 0")
		//
		// BENEFIT: Non-Stata users can document corrections!
		// EFFICIENCY: Replaces 100+ manual replace commands
	
	* Save corrected version
	save "$raw/survey_corrected_`current_date'.dta", replace
		// IMPORTANT: Save after major steps!
	
	
	*---------------------------------------------------*
	* 3.2 Resolve duplicates systematically
	*
	* BEST PRACTICE: Use ieduplicates (World Bank method)
	*---------------------------------------------------*
	
	* Step 1: Export duplicates for team review
	ieduplicates unique_id using "$corrections/duplicates_list.xlsx", ///
		uniquevars(unique_id) ///
		keepvars(enum_id interview_date village_name) ///
		folder("$hfc_output/duplicates")
		// CREATES: Excel file listing all duplicate IDs
		// INCLUDES: Key variables to help identify correct record
		// TEAM REVIEWS: Decides which to keep/drop in Excel
	
	/* TEAM DOES IN EXCEL (no Stata skills needed!):
	   For each duplicate pair, specify in Excel:
	   - "keep" for observation to keep
	   - "drop" for observation to delete
	   - "correct" if ID needs fixing (with new ID value)
	   - Comment explaining decision
	*/
	
	* Step 2: Apply duplicate resolutions from Excel
	ieduplicates unique_id using "$corrections/duplicates_list.xlsx", ///
		uniquevars(unique_id) ///
		folder("$hfc_output/duplicates")
		// READS: Team's decisions from Excel
		// APPLIES: Drops marked observations, corrects IDs
		// LOGS: All changes made
	
	* Step 3: Verify no duplicates remain
	isid unique_id
		// Checks if unique_id is truly unique
		// GIVES ERROR if duplicates still exist
		// NO ERROR = success! Each ID appears exactly once
		
	/* FOR LARGE DATASETS: Use faster version
	gisid unique_id
		// Same as isid but 92% faster
		// Use when you have 500k+ observations
	*/
	
	
	*---------------------------------------------------*
	* 3.3 Merge half-complete surveys (IF APPLICABLE)
	*
	* SKIP THIS if you don't have revisit surveys
	*---------------------------------------------------*
	
	/* SCENARIO: Some surveys completed in multiple sessions
	   Example: 
	   - Visit 1: Answered demographics (modules 1-2)
	   - Visit 2: Answered health questions (modules 3-4)
	   Need to combine both into one complete record
	
	   See detailed merging code in efficiency workflow guide
	   Key concept: Use "update replace" merge strategy
	*/


/****************************************************************************
	4. DROP IRRELEVANT VARIABLES
	
	PURPOSE: Remove clutter, focus on analysis variables
	TIME: 10 minutes
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


/****************************************************************************
	5. VARIABLE CLEANING
	
	PURPOSE: Standardize data format and fix inconsistencies
	TIME: 45 minutes
****************************************************************************/

	*---------------------------------------------------*
	* 5.1 Convert special missing values
	*
	* PROBLEM: Survey tools use codes like -999, -55
	* ISSUE: Stata treats these as actual numbers!
	* SOLUTION: Convert to Stata missing values (.r, .d, .h)
	*---------------------------------------------------*
	
	/*==================================================================
		Understanding the conversion: //Pre-decide the codes during SCTO coding with the team
		
		Survey code → Stata missing → Meaning
		-888, 888   → .r          → Refused to answer
		-999, 999     → .d          → Don't know
		-22, 22     → .h          → Not applicable 
		-777, 777   → .h          → Half complete
		-66, 66     → (keep)      → Other (specify) - often used
	==================================================================*/
	
	** Step 1: Fix SurveyCTO double underscore issue
	foreach suffix in 55 777 888 999 22 {
		// For each special code
		foreach var of varlist *__`suffix' {
			// Find variables with double underscore
			local newname = subinstr("`var'", "__`suffix'", "_`suffix'", .)
			rename `var' `newname'
			// Changes: age__999 → age_999
		}
	}
	
	** Step 2: Label special code variables
	
	foreach var of varlist *_777 {
		label variable `var' "Half complete"
	}
	foreach var of varlist *_888 {
		label variable `var' "Refuse to answer"
	}
	foreach var of varlist *_999 {
		label variable `var' "Don't know"
	}
	foreach var of varlist *_22 {
		label variable `var' "Not applicable"
	}
	foreach var of varlist *_66 {
		label variable `var' "Other (specify)"
	}
	
	** Step 3: Convert STRING variables
	ds, has(type string)
		// Get list of all string variables
	local string_vars `r(varlist)'
	
	* Exclude ID variables (never convert these!)
	local id_vars unique_id facility_id region_id district_id key
	local string_vars: list string_vars - id_vars
		// Remove ID vars from conversion list
	
	foreach v of local string_vars {
		replace `v' = ".r" if inlist(`v', "888", "-888")      // Refused
		replace `v' = ".d" if inlist(`v', "999", "-999")        // Don't know
		replace `v' = ".h" if inlist(`v', "22", "-22", "777", "-777")  // NA/half complete
	}
	
	** Step 4: Convert NUMERIC variables
	ds, has(type numeric)
		// Get list of all numeric variables
	
	foreach v in `r(varlist)' {
		mvdecode `v', mv(-888 = .r \ -999 = .d \ -22 = .h \ -777 = .h)
		mvdecode `v', mv(888 = .r \ 999 = .d \ 22 = .h \ 777 = .h)
		recode `v' (.888 = .r) (.999 = .d) (.22 = .h) (.777 = .h)
			// Handles both negative and positive codes
			// Also handles decimal versions (.999, .22, etc.)
	}
	
	** Step 5: Define and apply missing value labels
	label define missings .r "Refused" .d "Don't know" ///
		.h "Half complete/Not applicable" .s "Skipped", replace
	
	foreach v of varlist _all {
		capture confirm numeric variable `v'
		if _rc == 0 {
			local labelname : value label `v'
			if "`labelname'" != "" {
				label define `labelname' .r "Refused" .d "Don't know" ///
					.h "Half complete/NA" .s "Skipped", add
			}
		}
	}
	
	
	*---------------------------------------------------*
	* 5.2 Extract multiple response variables
	*
	* CONCEPT: "Select all that apply" questions
	* STORED AS: "1 3 5" (space-separated)
	* NEEDED: Separate dummy for each option in case SCTO dummy variables aren't reliable and the team decides to manually create binary variables 
	*---------------------------------------------------*
	
	* Create reusable program
	program define process_multiselect
		args varname maxnum special_codes
		
		tostring `varname'_?, replace
		
		forvalues num = 1/`maxnum' {
			replace `varname'_`num' = "0" if !regexm(`varname', "(`num')")
			replace `varname'_`num' = "1" if regexm(`varname', "(`num')")
			replace `varname'_`num' = `varname' if ///
				regexm(`varname', "(.s|.d|.r|.h)")
			destring `varname'_`num', replace
		}
		
		foreach code in `special_codes' {
			tostring `varname'_`code', replace force
			replace `varname'_`code' = "0" if !regexm(`varname', "(`code')")
			replace `varname'_`code' = "1" if regexm(`varname', "(`code')")
			replace `varname'_`code' = `varname' if ///
				regexm(`varname', "(.s|.d|.r|.h)")
			destring `varname'_`code', replace
		}
	end
	
	* Use program on your multi-select variables
	process_multiselect health_services 8 "88 999"
		// REPLACE: health_services with your variable name
		// REPLACE: 8 with number of options
		// REPLACE: "88 999" with your special codes
	
	process_multiselect food_groups 12 "88 999"
	process_multiselect barriers 6 "55 88 999"
		// Add more as needed for your survey
	
	
	*---------------------------------------------------*
	* 5.3 Destring variables (convert text to numbers)
	*
	* PROBLEM: Numbers sometimes stored as text
	* SOLUTION: Convert to actual numbers
	*---------------------------------------------------*
	
	destring _all, replace
		// Tries to convert all variables
		// Only converts if possible (all digits)
		// Skips text variables (names, addresses, etc.)
		// REVIEW: Output shows which variables converted
	
	
	*---------------------------------------------------*
	* 5.4 Clean string variables
	*
	* GOAL: Make text consistent
	* PROBLEM: "Christian" vs "christian" vs " Christian "
	* SOLUTION: Standardize formatting
	*---------------------------------------------------*
	
	* List your text variables
	local text_to_clean village_name occupation religion language
		// CUSTOMIZE: Add your string variables here
	
	foreach v of local text_to_clean {
		replace `v' = trim(`v')
			// Remove leading/trailing spaces
		replace `v' = itrim(`v')
			// Remove multiple internal spaces
		replace `v' = proper(`v')
			// Capitalize first letter: "john" → "John"
	}
	
	
	*---------------------------------------------------*
	* 5.5 Recode "Other (specify)" efficiently
	*
	* OLD WAY: 100+ manual replace commands
	* NEW WAY: Excel-based recoding with one command
	*---------------------------------------------------*
	
	* Apply recoding from Excel file
	foreach var of varlist *_oth *_o {
		capture ipacheckspecifyrecode using "$corrections/other_specify_recode.xlsx", ///
			sheet("`var'") ///
			id(key) ///
			nolabel
			// READS: Excel file with recoding rules
			// APPLIES: All recodings automatically
			//
			// EXCEL STRUCTURE NEEDED:
			// Sheet name: Same as variable (e.g., religion_oth)
			// Column A: key (ID)
			// Column B: old_value (text response)
			// Column C: new_value (code to assign)
			//
			// Example:
			// key      | old_value  | new_value
			// HH_001   | Catholic   | 1
			// HH_023   | Protestant | 1
			// HH_045   | Muslim     | 2
	}
	
	* Manual recoding for remaining cases
	replace religion = 1 if regexm(lower(religion_oth), "christian|catholic|protestant")
	replace religion = 2 if regexm(lower(religion_oth), "muslim|islam")
	replace religion = 3 if regexm(lower(religion_oth), "hindu")
		// regexm() = "regular expression match"
		// lower() = convert to lowercase first
		// | = OR (matches any of these words)
	
	
	*---------------------------------------------------*
	* 5.6 Standardize units
	*
	* PROBLEM: Inconsistent units in data
	* EXAMPLES: Some ages in years, some in months
	*           Some heights in cm, some in meters
	*---------------------------------------------------*
	
	* Convert ages to years (if some in months)
	replace age = age / 12 if age > 120
		// If age > 120, probably in months (convert to years)
		// Example: 240 months = 240/12 = 20 years
		// Why 120? Anyone over 120 years is unrealistic
	
	* Convert heights to meters (if some in cm)
	replace height = height / 100 if height > 10
		// If height > 10, probably in cm (convert to meters)
		// Example: 175 cm = 175/100 = 1.75 meters
		// Why 10? No one is 10 meters tall!
	
	* Verify conversions worked
	summarize age height
		// Check: Ranges now make sense?


/****************************************************************************
	6. DATA VALIDATION AND QUALITY CHECKS -- can be done in HFCs
	
	PURPOSE: Ensure data follows logical rules
	TIME: 30 minutes
****************************************************************************/

	*---------------------------------------------------*
	* 6.1 Check for outliers (extreme values)
	*---------------------------------------------------*
	
	* AUTOMATED METHOD (easiest)
	ipacheckoutliers using "$hfc/hfc_inputs.xlsm", ///
		sheet("outliers") ///
		id(unique_id) ///
		enum(enum_id) ///
		outfile("$hfc_output/outliers_final.xlsx") ///
		sd(3)
		// Flags values >3 standard deviations from mean
		// Review Excel output for each flagged case
	
	* MANUAL METHOD (for learning/custom logic)
	local outlier_vars age height weight income household_size
	
	foreach v of local outlier_vars {
		qui sum `v', detail
		qui gen `v'_sd = abs((`v' - r(mean))) / (r(sd))
		qui gen flag_`v' = `v'_sd > 1.96 & !mi(`v') & `r(N)' > 25
		
		qui count if flag_`v' == 1
		if r(N) > 0 {
			di "`v' has `r(N)' outliers"
			list unique_id `v' if flag_`v' == 1
		}
		
		drop `v'_sd
	}
	
	
	*---------------------------------------------------*
	* 6.2 Check logical constraints
	*
	* VERIFY: Data follows expected rules
	*---------------------------------------------------*
	
	* Age should be in reasonable range
	assert age >= 18 & age <= 100 if !missing(age)
		// STOPS with error if any age < 18 or > 100
		// IF ERROR: list unique_id age if age<18 | age>100
	
	* Total children should equal sum of boys + girls
	assert children_boys + children_girls == children_total ///
		if !missing(children_total)
		// IF ERROR: Mathematical inconsistency found
	
	* Interview date should be after survey start
	assert interview_date >= d(01jan2025)
		// CUSTOMIZE: Use your survey start date
	
	* Birth year should be before interview year
	assert birth_year <= year(interview_date)
		// Can't be born in future!
	
	
	*---------------------------------------------------*
	* 6.3 Check missing patterns
	*---------------------------------------------------*
	
	* Overall missing summary
	misstable summarize
		// Shows % missing for each variable
	
	* Detailed missing analysis
	misstable summarize, gen(missvar_) exok
		// Creates flag variables: missvar_age, missvar_income, etc.
		// = 1 if missing, 0 if not missing
	
	* Review unexpected missings
	foreach missvar of varlist missvar_* {
		qui count if `missvar' == 1
		if r(N) != 0 {
			di "`missvar' has `r(N)' unexplained missing values"
		}
	}
	
	drop missvar_*
		// Clean up temporary flags


/****************************************************************************
	7. CREATE AND TRANSFORM VARIABLES
	
	PURPOSE: Create analysis-ready variables
	TIME: 45 minutes
****************************************************************************/

	*---------------------------------------------------*
	* 7.1 Create/verify unique identifiers
	*
	* CRITICAL: Every observation needs unique ID
	*---------------------------------------------------*
	
	* If creating ID from hierarchical structure
	egen uid_str = concat(province_id district_id village_id hh_id), ///
		format(%02.0f %02.0f %03.0f %03.0f)
		// Combines multiple IDs into one
		// %02.0f = 2 digits (01, 02, ..., 99)
		// %03.0f = 3 digits (001, 002, ..., 999)
		// Example: 01-05-023-156 = Province 1, District 5, Village 23, HH 156
	
	gen unique_id = "1" + uid_str
		// Add prefix to prevent leading zero issues
		// Example: 10105023156
	
	drop uid_str
	
	* Verify uniqueness
	isid unique_id
		// STOPS with error if duplicates exist
		// NO ERROR = success!
	
	
	*---------------------------------------------------*
	* 7.2 Recode categorical variables
	*
	* PURPOSE: Collapse categories, create groups
	*---------------------------------------------------*
	
	* Education into broad categories
	recode education ///
		(0/2 = 1 "Primary or less") ///
		(3/4 = 2 "Secondary") ///
		(5/8 = 3 "Tertiary"), ///
		gen(educ_level)
		// Old categories 0,1,2 → New category 1 "Primary or less"
		// Old categories 3,4 → New category 2 "Secondary"
		// Old categories 5,6,7,8 → New category 3 "Tertiary"
		// gen() = create NEW variable (keeps original too)
	
	label var educ_level "Educational attainment (3 categories)"
	
	* Age into groups
	recode age ///
		(18/24 = 1 "18-24 years") ///
		(25/34 = 2 "25-34 years") ///
		(35/44 = 3 "35-44 years") ///
		(45/54 = 4 "45-54 years") ///
		(55/100 = 5 "55+ years"), ///
		gen(age_group)
	
	label var age_group "Age group (5 categories)"
	
	* Wealth into quintiles
	xtile wealth_quintile = wealth_index, nquantiles(5)
		// Divides into 5 equal groups
		// 1 = poorest 20%, 5 = richest 20%
	
	label define wealth_quintile 1 "Poorest" 2 "Poor" 3 "Middle" ///
		4 "Rich" 5 "Richest"
	label values wealth_quintile wealth_quintile
	
	
	*---------------------------------------------------*
	* 7.3 Create dummy variables
	*
	* CONCEPT: Binary 0/1 variables
	* PURPOSE: Easier for regression, clear interpretation
	*---------------------------------------------------*
	
	* From categorical variable (automatic)
	tab education, gen(educ_)
		// Creates: educ_1, educ_2, educ_3, etc.
		// Each = 1 if that category, 0 otherwise
	
	* Manual creation (more control)
	gen female = (gender == 2) if !missing(gender)
		// = 1 if gender is 2 (female)
		// = 0 if gender is not 2 (male/other)
		// = . if gender is missing
	
	label var female "Respondent is female"
	label define yesno 0 "No" 1 "Yes"
	label values female yesno
	
	gen urban = (area_type == 1) if !missing(area_type)
	label var urban "Urban area"
	label values urban yesno
	
	gen employed = (employment_status == 1) if !missing(employment_status)
	label var employed "Currently employed"
	label values employed yesno
	
	
	*---------------------------------------------------*
	* 7.4 Create indices and composite scores
	*---------------------------------------------------*
	
	* Sum score (total of multiple items)
	egen total_score = rowtotal(item1 item2 item3 item4 item5)
		// Adds: Values across items for each observation
		// Example: item1=2, item2=3, item3=1 → total=6
	
	egen missing_items = rowmiss(item1 item2 item3 item4 item5)
		// Counts: How many items are missing
	
	replace total_score = . if missing_items > 0
		// If any items missing, total score = missing
		// WHY: Unfair to compare 5-item sum with 3-item sum
	
	drop missing_items
	label var total_score "Total score (5 items)"
	
	* Mean score (average of items)
	egen mean_score = rowmean(item1 item2 item3 item4 item5)
		// Calculates: Average across items
		// Handles missing automatically (excludes from average)
	
	label var mean_score "Mean score (5 items)"
	
	* Standardized score (z-score)
	egen std_score = std(total_score)
		// Converts: To standard deviations from mean
		// Mean = 0, SD = 1
		// Useful for: Comparing across different scales
	
	label var std_score "Standardized total score"


/****************************************************************************
	8. METADATA: LABELS AND DOCUMENTATION
	
	PURPOSE: Make data self-documenting and understandable
	TIME: 30 minutes (or 5 minutes with iecodebook!)
****************************************************************************/

	*---------------------------------------------------*
	* 8.1 EFFICIENT METHOD: Use iecodebook (RECOMMENDED)
	*
	* WORKFLOW:
	* 1. Export template
	* 2. Fill in Excel (whole team can help!)
	* 3. Apply with one command
	*---------------------------------------------------*
	
	* Step 1: Generate template from current dataset
	iecodebook template using "$cleaning/codebook_template.xlsx"
		// CREATES: Excel file with all current variables
		// INCLUDES: Current names, labels, types
		// TEAM FILLS: Desired labels, renames, recodes
	
	/* Step 2: Edit in Excel (done by team)
	   
	   In Excel file, fill these columns:
	   - rename: New variable name (if changing)
	   - varlabel: Descriptive variable label
	   - vallabel: Name of value label set
	   - choices: Value label definitions
	   - recode: Recode specifications
	   - drop: Mark "yes" to drop variable
	   
	   Example:
	   ┌──────────┬────────┬─────────────────────┬──────────┬─────────────┐
	   │ name     │ rename │ varlabel            │ vallabel │ choices     │
	   ├──────────┼────────┼─────────────────────┼──────────┼─────────────┤
	   │ q1_age   │ age    │ Age in years        │ age_lbl  │             │
	   │ q2_sex   │ gender │ Respondent gender   │ gender   │ 1=Male;2=Fem│
	   │ q3_edu   │ educ   │ Education level     │ educ_lbl │ 1=None;2=Pr │
	   └──────────┴────────┴─────────────────────┴──────────┴─────────────┘
	*/
	
	* Step 3: Apply all changes with ONE command
	iecodebook apply using "$cleaning/codebook_completed.xlsx", ///
		drop
		// APPLIES:
		// - All renames
		// - All variable labels
		// - All value labels
		// - All recodes
		// - Drops marked variables
		//
		// REPLACES: Potentially 500+ lines of manual code!
		// TIME SAVED: 6-8 hours → 30 minutes
	
	
	*---------------------------------------------------*
	* 8.2 MANUAL METHOD: Individual labeling
	*
	* USE ONLY IF: Not using iecodebook
	* OR: For quick additions
	*---------------------------------------------------*
	
	* Variable labels (describe what variable represents)
	label var unique_id "Unique household identifier"
	label var age "Age in years"
	label var gender "Respondent gender"
	label var income "Monthly household income in pesos"
	label var education "Highest education level completed"
	
	* Value labels (what each number means)
	
	** Step 1: Define label sets
	label define yesno 0 "No" 1 "Yes" .d "Don't know" .r "Refused" .s "Skipped"
	label define gender 1 "Male" 2 "Female" 3 "Other/Prefer not to say"
	label define educ 1 "No schooling" 2 "Primary" 3 "Secondary" 4 "Tertiary"
	
	** Step 2: Attach labels to variables
	label values consent yesno
	label values improved yesno
	label values gender gender
	label values education educ
	
	
	*---------------------------------------------------*
	* 8.3 Add notes to variables  - OPTIONAL
	*
	* PURPOSE: Document important details
	* BENEFIT: Future you will thank you!
	*---------------------------------------------------*
	
	* Document data source
	note age: "Self-reported age in years. Source: Survey Q2.1"
	
	* Document calculations
	note bmi: "Body Mass Index. Calculated as weight(kg) / height(m)^2"
	note total_income: "Sum of income from all sources reported"
	
	* Document corrections
	note income: "Outliers >1M verified with field team 2025-01-15"
	
	* Dataset-level notes
	note: "Dataset cleaned on `c(current_date)' by `c(username)'"
	note: "Raw data: $raw/household_survey_raw.dta"
	note: "Cleaning script: $cleaning/cleaning_master.do"
	note: "HFC review period: 2025-01-10 to 2025-01-31"
	
	
	*---------------------------------------------------*
	* 8.4 Document skip patterns
	*
	* PURPOSE: Record which questions were skipped and why
	*---------------------------------------------------*
	
	* Example: Follow-up only asked if main question = yes
	replace follow_up_q = .s if main_q == 0 & missing(follow_up_q)
		// .s = "skipped" (due to logic)
		// If main question answered "no" (0), follow-up was skipped
	
	note follow_up_q: "Skipped if main_q == 0 (answered No)"
	
	* Example: Vaccine dosage only asked if vaccine received
	replace vaccine_dose = .s if vaccine_received != 1 & missing(vaccine_dose)
	note vaccine_dose: "Skipped if vaccine_received != 1"
	
	* Verify skip patterns are complete
	assert follow_up_q == .s | !missing(follow_up_q)
		// CHECKS: Variable is either skipped (.s) OR has value
		// Should NOT be regular missing (.)


/****************************************************************************
	9. DE-IDENTIFICATION AND DATA PROTECTION
	
	PURPOSE: Protect respondent privacy
	TIME: 20 minutes
	IMPORTANCE: CRITICAL for ethics and legal compliance
****************************************************************************/

	/*==================================================================
		What is PII (Personally Identifiable Information)?
		
		DIRECT IDENTIFIERS (can identify person directly):
		- Names (respondent, household head, children)
		- Phone numbers
		- Email addresses
		- National ID numbers
		- Exact GPS coordinates (can locate house)
		- Photos with faces
		- Voice recordings
		
		INDIRECT IDENTIFIERS (combination can identify):
		- Age + Gender + Village (if village is small)
		- Rare occupation + Location
		- Unique characteristics mentioned
		
		WHY REMOVE?
		- Protect respondent privacy
		- Comply with ethics (IRB requirements)
		- Comply with laws (GDPR, local regulations)
		- Prevent misuse of data
		- Enable data sharing
	==================================================================*/
	
	*---------------------------------------------------*
	* 9.1 Separate PII data (save separately, encrypted)
	*---------------------------------------------------*
	
	preserve
		// SAVES: Current dataset state (can restore later)
		// WHY: So we can extract PII without losing main data
	
		* Keep only ID and PII variables
		keep unique_id respondent_name household_head_name ///
			phone_number national_id ///
			gps_latitude gps_longitude exact_address ///
			child_name_1 child_name_2
			// CUSTOMIZE: Add all PII variables in your data
		
		* Save PII dataset in encrypted location
		save "$clean_pii/survey_pii_`current_date'.dta", replace
			// CRITICAL: This folder must be encrypted/password-protected
			// ACCESS: Only authorized team members
			// SHARING: Never share this file publicly
	
	restore
		// RETURNS: To full dataset (with all variables)
	
	
	*---------------------------------------------------*
	* 9.2 Remove PII from main dataset
	*---------------------------------------------------*
	
	* Drop direct identifiers
	drop respondent_name household_head_name ///
		phone_number national_id email ///
		child_name_1 child_name_2 child_name_3 ///
		enum_name enum_phone ///
		exact_address street_address
		// CUSTOMIZE: Drop all PII variables in your dataset
		//
		// IMPORTANT: Double-check you're not dropping:
		// - enum_id (useful for analysis, not identifying if coded)
		// - unique_id (needed, not PII if properly coded)
	
	* Mask indirect identifiers (if needed)
	
	** Option 1: Round GPS to broader area
	gen gps_lat_approx = round(gps_latitude, 0.01)
	gen gps_lon_approx = round(gps_longitude, 0.01)
		// Rounds to ~1km area instead of exact location
		// Still useful for mapping, but not pinpoint house
	
	drop gps_latitude gps_longitude
	
	** Option 2: Drop small geographic units
	* drop village_name
		// If village is small, combination of village + age + gender
		// might identify respondent
		// Keep only district level for small samples
	
	
	*---------------------------------------------------*
	* 9.3 Verify de-identification complete
	*---------------------------------------------------*
	
	* Check no name/phone variables remain
	ds *name* *phone* *address*, not
		// Lists all variables NOT containing these words
		// If returns complete list = good!
		// If error "no variables" = still have PII, check again
	
	* Document de-identification
	note: "PII removed on `current_date'"
	note: "PII stored separately in encrypted folder: $clean_pii"
	note: "This dataset is de-identified and safe to share with analysts"


/****************************************************************************
	10. ORDER, SORT, AND SAVE
	
	PURPOSE: Organize dataset professionally
	TIME: 10 minutes
****************************************************************************/

	*---------------------------------------------------*
	* 10.1 Order variables logically
	*
	* GOAL: Related variables grouped together
	* BENEFIT: Easier to navigate, more professional
	*---------------------------------------------------*
	
	* Geographic/administrative variables first
	order unique_id region_id province_id district_id village_id urban_rural
		// IDs and location variables at start
	
	* Demographics next
	order age gender education occupation income, after(village_id)
		// after() = place these after specified variable
	
	* Survey modules in order they appeared
	order module1_*, after(income)
		// All module 1 variables together
	order module2_*, after(module1_var_last)
		// Module 2 after module 1
	order module3_*, after(module2_var_last)
		// And so on...
	
	* Weights and technical variables last  - based on team preference
	order weight_* strata_*, last
		// last = put at end of dataset
	
	
	*---------------------------------------------------*
	* 10.2 Sort dataset
	*
	* GOAL: Logical row order
	* BENEFIT: Easier to browse, merge, append
	*---------------------------------------------------*
	
	* By geographic hierarchy
	sort region_id province_id district_id village_id household_id
		// Creates natural ordering
		// All households in same village together, etc.
	
	* OR by unique ID
	* sort unique_id
		// Alphabetical/numerical order by ID
	
	
	*---------------------------------------------------*
	* 10.3 Compress dataset
	*
	* GOAL: Reduce file size
	* BENEFIT: Faster to load, easier to share, saves space
	*---------------------------------------------------*
	
	compress
		// Optimizes storage type for each variable
		// Example: Variable with values 1-5 stored as byte (1 byte)
		//          instead of float (4 bytes)
		// Can reduce file size by 50-80%!
		// Doesn't change data, only storage efficiency
		// ALWAYS run before final save!
	
	
	*---------------------------------------------------*
	* 10.4 Save cleaned dataset
	*
	* STRATEGY: Multiple saves at different stages
	*---------------------------------------------------*
	
	* Main cleaned dataset (no PII)
	save "$clean_nopii/survey_cleaned.dta", replace
		// This is your PRIMARY analysis dataset
		// Safe to share with team members
	
	* Export to other formats if needed
	export delimited using "$output/survey_cleaned.csv", replace
		// CSV format for Excel, R, Python users
	
	* Version with date stamp (good practice!)
	save "$clean_nopii/survey_cleaned_`current_date'.dta", replace
		// Allows tracking changes over time
		// Can always revert to earlier version if needed


/****************************************************************************
	11. CLOSE LOG AND FINISH
	
	PURPOSE: Complete documentation and clean up
	TIME: 2 minutes
****************************************************************************/

capture log close
	// Stops recording to log file
	// Log is now saved and complete

* Display completion message
di ""
di "═══════════════════════════════════════════════════════════════"
di "✓ DATA CLEANING COMPLETED SUCCESSFULLY!"
di "═══════════════════════════════════════════════════════════════"
di ""
di "📊 OUTPUTS CREATED:"
di "   Cleaned dataset: $clean_nopii/survey_cleaned_`current_date'.dta"
di "   CSV export: $output/survey_cleaned.csv"
di "   Log file: $logs/cleaning_`current_date'.log"
di "   PII dataset: $clean_pii/survey_pii_`current_date'.dta"
di ""
di "📈 SAMPLE SIZE:"
qui count
di "   Final observations: " r(N)
di ""
di "📋 NEXT STEPS:"
di "   1. Review log file for any warnings"
di "   2. Check final dataset: use $clean_nopii/survey_cleaned.dta"
di "   3. Create codebook: iecodebook export"
di "   4. Begin analysis!"
di ""
di "═══════════════════════════════════════════════════════════════"

exit
	// Ends program cleanly


/*##############################################################################

	APPENDIX A: COMMON CUSTOMIZATIONS

##############################################################################*/

/*===========================================================================
	A.1 Different special missing codes
	
	IF YOUR SURVEY USES DIFFERENT CODES, modify Section 5.1
	
	Find and replace:
	-999 → your refuse code
	-55  → your don't know code
	-22  → your NA code
	-777 → your half-complete code
===========================================================================*/

/*===========================================================================
	A.2 Different survey status codes
	
	IF YOUR COMPLETION CODE IS DIFFERENT, modify Section 1.3
	
	Examples:
	keep if survey_status == 2  // If 2 = complete
	keep if survey_status == "Complete"  // If text
	keep if complete_yn == 1  // If different variable name
===========================================================================*/

/*===========================================================================
	A.3 Multiple survey forms
	
	IF YOU HAVE MULTIPLE FORMS, run this script for each
	
	Example:
	- household_cleaning.do (this script for household survey)
	- facility_cleaning.do (copy and modify for facility survey)
	- community_cleaning.do (copy and modify for community survey)
	
	Then append:
	use household_clean.dta, clear
	append using facility_clean.dta
	append using community_clean.dta
	save combined_clean.dta, replace
===========================================================================*/


/*##############################################################################

	APPENDIX B: TROUBLESHOOTING GUIDE

##############################################################################*/

/*===========================================================================
	ERROR: "no; data in memory would be lost"
	
	CAUSE: Forgot to add ", clear" when loading data
	FIX: use "$raw/survey.dta", clear  (add clear!)
===========================================================================*/

/*===========================================================================
	ERROR: "file not found"
	
	CAUSE: Wrong file path or name
	FIX:
	1. Check spelling (case-sensitive!)
	2. Verify file exists: dir "$raw"
	3. Check file extension (.dta vs .csv)
===========================================================================*/

/*===========================================================================
	ERROR: "variable not found"
	
	CAUSE: Typo in variable name
	FIX:
	1. Check spelling: describe (shows all variable names)
	2. Check case: age vs Age vs AGE (different in Stata!)
	3. Was variable dropped earlier? Review code above
===========================================================================*/

/*===========================================================================
	ERROR: "assertion is false"
	
	CAUSE: Data doesn't meet expected condition
	FIX:
	1. List problematic observations:
	   list unique_id var if condition_not_met
	2. Investigate: Are these errors or valid unusual cases?
	3. Add to corrections file if errors
	4. Adjust assertion if valid cases
===========================================================================*/

/*===========================================================================
	ERROR: ipacheckcorrections not found
	
	CAUSE: ipacheck package not installed
	FIX: Run Section 0.1 installation code
===========================================================================*/

/*===========================================================================
	WARNING: "could not be converted" (from destring)
	
	CAUSE: Variable has non-numeric text
	FIX:
	1. Check what's there: tab variable
	2. If should be numeric: investigate why text exists
	3. If should be text: don't destring
===========================================================================*/


/*##############################################################################

	APPENDIX C: QUICK REFERENCE

##############################################################################*/

/*===========================================================================
	File paths created in this script:
	
	$db           = Main project folder
	$raw          = Raw data (never modify!)
	$clean        = Cleaned data
	$clean_pii    = PII data (encrypted)
	$clean_nopii  = Non-PII data (shareable)
	$corrections  = Correction Excel files
	$hfc_output   = HFC results
	$logs         = Log files
	
	Use: $raw/filename.dta instead of full path
===========================================================================*/

/*===========================================================================
	Key commands used in this script:
	
	DATA MANAGEMENT:
	use, save, clear, append, merge
	
	INSPECTION:
	describe, codebook, browse, list, tab, summarize
	
	FILTERING:
	keep, drop, keep if, drop if
	
	VARIABLES:
	generate, replace, rename, recode, egen
	
	LABELS:
	label variable, label define, label values
	
	QUALITY:
	duplicates, isid, assert, missing
	
	Type "help command" for detailed help on any command
===========================================================================*/


/*##############################################################################

	APPENDIX D: CHECKLIST BEFORE FINISHING

##############################################################################*/

/*
Complete this checklist before claiming "cleaning is done":

DATA QUALITY:
☐ No duplicate IDs (verified with isid)
☐ All corrections applied and logged
☐ Outliers reviewed and handled
☐ Missing patterns understood and documented
☐ Skip patterns verified and documented
☐ All assertions pass (no logical inconsistencies)

VARIABLE QUALITY:
☐ All variables have descriptive labels
☐ All categorical variables have value labels
☐ All special missing values converted (.r, .d, .h, .s)
☐ All text variables cleaned (trim, proper/upper)
☐ All multi-select variables extracted to dummies
☐ All units standardized (ages in years, heights in meters, etc.)
☐ No variables named var1, var2, x, y (use descriptive names!)

DOCUMENTATION:
☐ Codebook exported (iecodebook export)
☐ Variable notes added for computed/important variables
☐ Dataset notes added (who, when, source)
☐ Skip patterns documented with notes
☐ All corrections logged
☐ Cleaning script runs start-to-finish without errors

DE-IDENTIFICATION:
☐ PII saved separately in encrypted folder
☐ All names removed from main dataset
☐ All phone numbers removed
☐ All exact GPS removed or masked
☐ All other PII removed
☐ Verified with: ds *name* *phone*, not

ORGANIZATION:
☐ Variables ordered logically
☐ Dataset sorted appropriately
☐ Dataset compressed
☐ Raw data still untouched in $raw folder
☐ Log file saved and reviewed

REPRODUCIBILITY:
☐ Script runs on clean Stata session (test it!)
☐ All file paths use globals (no hard-coded paths)
☐ Someone else could run this code
☐ All decisions documented (why we did things)

READY FOR ANALYSIS:
☐ Final dataset saved with clear name
☐ CSV exported if needed
☐ Codebook available for team
☐ README written explaining data structure
☐ Metadata documented

If all boxes checked: CONGRATULATIONS! Your data is analysis-ready! 🎉
*/


/*##############################################################################

	APPENDIX E: EFFICIENCY TIPS FOR LARGE DATASETS

##############################################################################*/

/*===========================================================================
	If you have 500,000+ observations, use gtools for speed
	
	CONCEPT: gtools = faster versions of common commands
	BENEFIT: 60-95% time reduction!
===========================================================================*/

/*
REPLACE these commands:          WITH these (gtools versions):
collapse                    →    gcollapse
egen                        →    gegen
duplicates                  →    gduplicates
isid                        →    gisid
reshape                     →    greshape
xtile                       →    gquantiles, xtile
pctile                      →    gquantiles, pctile
levelsof                    →    glevelsof

EXAMPLE SPEED GAINS:
- collapse 10M rows: 45 seconds → 5 seconds (89% faster)
- duplicates check: 37 seconds → 2 seconds (94% faster)
- isid check: 33 seconds → 2 seconds (92% faster)

USAGE: Just add "g" prefix!
gcollapse (mean) avg_income, by(district)  // Instead of collapse
gisid unique_id  // Instead of isid
*/


/*##############################################################################

	APPENDIX F: TEAM COLLABORATION TIPS

##############################################################################*/

/*===========================================================================
	Excel-based workflows for non-Stata team members
	
	PRINCIPLE: Not everyone knows Stata, but everyone knows Excel!
	SOLUTION: Use Excel for documentation, Stata for execution
===========================================================================*/

/*
CORRECTIONS WORKFLOW:
1. Data manager runs HFCs → exports Excel with issues
2. Research assistant reviews Excel → documents corrections
3. Field coordinator verifies corrections → approves
4. Data manager runs ipacheckcorrections → applies all
5. Everyone can participate without Stata skills!

LABELING WORKFLOW:
1. Data manager exports codebook template (iecodebook template)
2. Research team fills labels in Excel (collaborative)
3. PI reviews and approves
4. Data manager applies (iecodebook apply)
5. Done in 1/10th the time of manual coding!

DUPLICATE RESOLUTION WORKFLOW:
1. Data manager exports duplicates (ieduplicates)
2. Field team reviews context → decides keep/drop in Excel
3. Data manager applies decisions (ieduplicates)
4. Systematic and documented!
*/


/*##############################################################################

	APPENDIX G: NEXT STEPS AFTER CLEANING

##############################################################################*/

/*
YOU'VE CLEANED THE DATA! NOW WHAT?

1. CREATE COMPREHENSIVE CODEBOOK
   iecodebook export using "$output/codebook_final.xlsx", replace
   - Share with collaborators
   - Required for data sharing/publication

2. GENERATE SUMMARY STATISTICS
   do "$cleaning/summary_statistics.do"
   - Basic descriptives
   - Check distributions
   - Verify everything makes sense

3. CREATE ANALYSIS DATASET
   - Keep only variables needed for analysis
   - Save as separate file
   - Helps analysis run faster

4. WRITE DATA DOCUMENTATION
   - README file explaining dataset
   - Variable definitions
   - Known limitations
   - Citation information

5. BEGIN ANALYSIS!
   - Now you have clean, documented, trustworthy data
   - Can focus on research questions
   - Results will be valid

6. ARCHIVE CLEANING MATERIALS
   - Save all HFC outputs
   - Save all correction files
   - Save all logs
   - Keep for future reference/audits
*/


/*##############################################################################

	APPENDIX H: LEARNING RESOURCES

##############################################################################*/

/*
FOR BEGINNERS:

1. STATA BASICS:
   - Type: help [command]  (e.g., help summarize)
   - UCLA Stata tutorials: https://stats.oarc.ucla.edu/stata/
   - Stata YouTube channel (official tutorials)

2. DATA CLEANING:
   - This do file! (read comments carefully)
   - Beginner's cheat sheet (separate document)
   - J-PAL data cleaning guide
   - IPA research resources

3. PACKAGE-SPECIFIC:
   - ipacheck exercise: ipacheck new, exercise
   - iefieldkit wiki: https://dimewiki.worldbank.org/Iefieldkit
   - gtools documentation: https://gtools.readthedocs.io

4. GETTING HELP:
   - Statalist forum (very helpful community)
   - Package maintainers (see documentation)
   - Your supervisor/mentor
   - ChatGPT for syntax help (verify output!)

5. PRACTICE:
   - Use sample datasets (sysuse auto)
   - Try each command separately
   - Make mistakes (that's how you learn!)
   - Build confidence gradually
*/


/*##############################################################################

	APPENDIX I: VERSION HISTORY

##############################################################################*/

/*
Track changes to this script:

Version 1.0 - 2025-01-15 - [YOUR NAME]
- Initial creation based on template
- Customized for [PROJECT NAME]

Version 1.1 - 2025-01-20 - [YOUR NAME]  
- Added missing value conversion
- Fixed outlier detection code
- Added age group recoding

Version 1.2 - 2025-01-25 - [REVIEWER NAME]
- Added constraints checks
- Improved commenting
- Added verification steps

[Continue documenting changes here]
*/


/** END OF DATA CLEANING DO FILE **/

/*##############################################################################

	FINAL REMINDERS:

	✓ Always keep raw data untouched
	✓ Save frequently at multiple checkpoints
	✓ Document WHY you made decisions (not just what)
	✓ Run HFCs daily during data collection
	✓ Use Excel for team collaboration
	✓ Test your code on subset first
	✓ Review log file for errors
	✓ Ask for help when stuck
	✓ Celebrate when done! 🎉

	ESTIMATED TIME SAVINGS vs MANUAL CLEANING: 70-85%

##############################################################################*/
