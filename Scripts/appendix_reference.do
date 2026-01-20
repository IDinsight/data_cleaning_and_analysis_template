/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Reference guide and appendices

	This file contains:
	- Common customizations
	- Troubleshooting guide
	- Quick reference
	- Checklists
	- Efficiency tips
	- Team collaboration tips
	- Next steps after cleaning
	- Learning resources

****************************************************************************/


/*##############################################################################

	APPENDIX A: COMMON CUSTOMIZATIONS

##############################################################################*/

/*===========================================================================
	A.1 Different special missing codes

	IF YOUR SURVEY USES DIFFERENT CODES, modify 05_variable_cleaning.do

	Find and replace:
	-999 -> your refuse code
	-55  -> your don't know code
	-22  -> your NA code
	-777 -> your half-complete code
===========================================================================*/

/*===========================================================================
	A.2 Different survey status codes

	IF YOUR COMPLETION CODE IS DIFFERENT, modify 01_import_inspect.do

	Examples:
	keep if survey_status == 2  // If 2 = complete
	keep if survey_status == "Complete"  // If text
	keep if complete_yn == 1  // If different variable name
===========================================================================*/

/*===========================================================================
	A.3 Multiple survey forms

	IF YOU HAVE MULTIPLE FORMS, run the cleaning pipeline for each

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
	FIX: Run installation code in 00_setup.do
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
[ ] No duplicate IDs (verified with isid)
[ ] All corrections applied and logged
[ ] Outliers reviewed and handled
[ ] Missing patterns understood and documented
[ ] Skip patterns verified and documented
[ ] All assertions pass (no logical inconsistencies)

VARIABLE QUALITY:
[ ] All variables have descriptive labels
[ ] All categorical variables have value labels
[ ] All special missing values converted (.r, .d, .h, .s)
[ ] All text variables cleaned (trim, proper/upper)
[ ] All multi-select variables extracted to dummies
[ ] All units standardized (ages in years, heights in meters, etc.)
[ ] No variables named var1, var2, x, y (use descriptive names!)

DOCUMENTATION:
[ ] Codebook exported (iecodebook export)
[ ] Variable notes added for computed/important variables
[ ] Dataset notes added (who, when, source)
[ ] Skip patterns documented with notes
[ ] All corrections logged
[ ] Cleaning script runs start-to-finish without errors

DE-IDENTIFICATION:
[ ] PII saved separately in encrypted folder
[ ] All names removed from main dataset
[ ] All phone numbers removed
[ ] All exact GPS removed or masked
[ ] All other PII removed
[ ] Verified with: ds *name* *phone*, not

ORGANIZATION:
[ ] Variables ordered logically
[ ] Dataset sorted appropriately
[ ] Dataset compressed
[ ] Raw data still untouched in $raw folder
[ ] Log file saved and reviewed

REPRODUCIBILITY:
[ ] Script runs on clean Stata session (test it!)
[ ] All file paths use globals (no hard-coded paths)
[ ] Someone else could run this code
[ ] All decisions documented (why we did things)

READY FOR ANALYSIS:
[ ] Final dataset saved with clear name
[ ] CSV exported if needed
[ ] Codebook available for team
[ ] README written explaining data structure
[ ] Metadata documented

If all boxes checked: CONGRATULATIONS! Your data is analysis-ready!
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
collapse                    ->    gcollapse
egen                        ->    gegen
duplicates                  ->    gduplicates
isid                        ->    gisid
reshape                     ->    greshape
xtile                       ->    gquantiles, xtile
pctile                      ->    gquantiles, pctile
levelsof                    ->    glevelsof

EXAMPLE SPEED GAINS:
- collapse 10M rows: 45 seconds -> 5 seconds (89% faster)
- duplicates check: 37 seconds -> 2 seconds (94% faster)
- isid check: 33 seconds -> 2 seconds (92% faster)

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
1. Data manager runs HFCs -> exports Excel with issues
2. Research assistant reviews Excel -> documents corrections
3. Field coordinator verifies corrections -> approves
4. Data manager runs ipacheckcorrections -> applies all
5. Everyone can participate without Stata skills!

LABELING WORKFLOW:
1. Data manager exports codebook template (iecodebook template)
2. Research team fills labels in Excel (collaborative)
3. PI reviews and approves
4. Data manager applies (iecodebook apply)
5. Done in 1/10th the time of manual coding!

DUPLICATE RESOLUTION WORKFLOW:
1. Data manager exports duplicates (ieduplicates)
2. Field team reviews context -> decides keep/drop in Excel
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

	APPENDIX I: VERSION HISTORY TEMPLATE

##############################################################################*/

/*
Track changes to cleaning scripts:

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


/*##############################################################################

	FINAL REMINDERS

##############################################################################*/

/*
- Always keep raw data untouched
- Save frequently at multiple checkpoints
- Document WHY you made decisions (not just what)
- Run HFCs daily during data collection
- Use Excel for team collaboration
- Test your code on subset first
- Review log file for errors
- Ask for help when stuck

ESTIMATED TIME SAVINGS vs MANUAL CLEANING: 70-85%
*/


/** END OF REFERENCE FILE **/
