/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Data import and initial inspection

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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
