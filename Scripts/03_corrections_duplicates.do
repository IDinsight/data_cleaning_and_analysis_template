/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Apply corrections and resolve duplicates

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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
