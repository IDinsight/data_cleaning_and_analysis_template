/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Master do file - runs complete data cleaning pipeline

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
	- Run section by section (not all at once) the first time
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
		- Install required packages (one-time)
		- Initialize environment
		- Set file paths
		- Start logging

	1. DATA IMPORT AND INSPECTION (5 minutes)
		- Load raw data
		- Basic inspection
		- Keep completed surveys only

	2. HIGH FREQUENCY CHECKS (Daily, 15 min)
		- Run comprehensive quality checks
		- Review outputs and document corrections
		NOTE: Usually run separately during data collection

	3. CORRECTIONS AND DUPLICATES (30 minutes)
		- Apply corrections from Excel
		- Resolve duplicates systematically
		- Merge half-complete surveys (if applicable)

	4. DROP IRRELEVANT VARIABLES (10 minutes)
		- Drop process/metadata variables
		- Drop empty variables
		- Drop test observations

	5. VARIABLE CLEANING (45 minutes)
		- Convert special missing values
		- Extract multiple response variables
		- Destring variables
		- Clean string variables
		- Recode "Other (specify)" responses
		- Standardize units and formats

	6. DATA VALIDATION AND QUALITY CHECKS (30 minutes)
		- Check outliers
		- Check constraints and logic
		- Check missing patterns
		- Verify computed variables

	7. CREATE AND TRANSFORM VARIABLES (45 minutes)
		- Create unique identifiers
		- Recode categorical variables
		- Create dummy variables
		- Create indices and scores
		- Create analysis-ready variables

	8. METADATA: LABELS AND DOCUMENTATION (30 minutes)
		- Export codebook template (iecodebook)
		- Apply labels from codebook
		- Add notes to variables
		- Document skip patterns

	9. DE-IDENTIFICATION AND DATA PROTECTION (20 minutes)
		- Separate PII data
		- Remove/mask PII from main dataset
		- Verify de-identification complete

	10. ORDER, SORT, AND SAVE (10 minutes)
		- Order variables logically
		- Sort dataset
		- Compress dataset
		- Save cleaned dataset
		- Close log

TOTAL TIME:
- First time: 4-6 hours (includes learning)
- After setup: 2-3 hours
- With automation: 30-60 minutes

_____________________________________________________________________________*/


/****************************************************************************
	RUN CLEANING PIPELINE
****************************************************************************/

* Set the scripts directory
global scripts "$db/Scripts"


/*---------------------------------------------------------------------------
	0. Environment Setup
---------------------------------------------------------------------------*/
do "$scripts/00_setup.do"


/*---------------------------------------------------------------------------
	1. Data Import and Inspection
---------------------------------------------------------------------------*/
do "$scripts/01_import_inspect.do"


/*---------------------------------------------------------------------------
	2. High Frequency Checks

	NOTE: This is usually run SEPARATELY during data collection, not as
	part of the main cleaning pipeline. Uncomment if you want to run HFCs
	as part of this master file.
---------------------------------------------------------------------------*/
* do "$scripts/02_hfc.do"


/*---------------------------------------------------------------------------
	3. Corrections and Duplicates
---------------------------------------------------------------------------*/
do "$scripts/03_corrections_duplicates.do"


/*---------------------------------------------------------------------------
	4. Drop Irrelevant Variables
---------------------------------------------------------------------------*/
do "$scripts/04_drop_variables.do"


/*---------------------------------------------------------------------------
	5. Variable Cleaning
---------------------------------------------------------------------------*/
do "$scripts/05_variable_cleaning.do"


/*---------------------------------------------------------------------------
	6. Data Validation and Quality Checks
---------------------------------------------------------------------------*/
do "$scripts/06_validation.do"


/*---------------------------------------------------------------------------
	7. Create and Transform Variables
---------------------------------------------------------------------------*/
do "$scripts/07_create_variables.do"


/*---------------------------------------------------------------------------
	8. Metadata: Labels and Documentation
---------------------------------------------------------------------------*/
do "$scripts/08_metadata.do"


/*---------------------------------------------------------------------------
	9. De-identification and Data Protection
---------------------------------------------------------------------------*/
do "$scripts/09_deidentification.do"


/*---------------------------------------------------------------------------
	10. Order, Sort, and Save
---------------------------------------------------------------------------*/
do "$scripts/10_save.do"


/** END OF MASTER DO FILE **/
