/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Variable cleaning and standardization

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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

	Survey code -> Stata missing -> Meaning
	-888, 888   -> .r          -> Refused to answer
	-999, 999     -> .d          -> Don't know
	-22, 22     -> .h          -> Not applicable
	-777, 777   -> .h          -> Half complete
	-66, 66     -> (keep)      -> Other (specify) - often used
==================================================================*/

** Step 1: Fix SurveyCTO double underscore issue
foreach suffix in 55 777 888 999 22 {
	// For each special code
	foreach var of varlist *__`suffix' {
		// Find variables with double underscore
		local newname = subinstr("`var'", "__`suffix'", "_`suffix'", .)
		rename `var' `newname'
		// Changes: age__999 -> age_999
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
		// Capitalize first letter: "john" -> "John"
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
