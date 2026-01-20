/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Labels, documentation, and metadata

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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
   +----------+--------+---------------------+----------+-------------+
   | name     | rename | varlabel            | vallabel | choices     |
   +----------+--------+---------------------+----------+-------------+
   | q1_age   | age    | Age in years        | age_lbl  |             |
   | q2_sex   | gender | Respondent gender   | gender   | 1=Male;2=Fem|
   | q3_edu   | educ   | Education level     | educ_lbl | 1=None;2=Pr |
   +----------+--------+---------------------+----------+-------------+
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
	// TIME SAVED: 6-8 hours -> 30 minutes


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
