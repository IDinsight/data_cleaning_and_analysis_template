/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Environment setup and initialization

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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

di "All packages installed successfully!"

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
