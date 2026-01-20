/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Order, sort, compress, and save final dataset

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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


*---------------------------------------------------*
* 10.5 Close log and display completion message
*---------------------------------------------------*

capture log close
	// Stops recording to log file
	// Log is now saved and complete

* Display completion message
di ""
di "==============================================================="
di "DATA CLEANING COMPLETED SUCCESSFULLY!"
di "==============================================================="
di ""
di "OUTPUTS CREATED:"
di "   Cleaned dataset: $clean_nopii/survey_cleaned_`current_date'.dta"
di "   CSV export: $output/survey_cleaned.csv"
di "   Log file: $logs/cleaning_`current_date'.log"
di "   PII dataset: $clean_pii/survey_pii_`current_date'.dta"
di ""
di "SAMPLE SIZE:"
qui count
di "   Final observations: " r(N)
di ""
di "NEXT STEPS:"
di "   1. Review log file for any warnings"
di "   2. Check final dataset: use $clean_nopii/survey_cleaned.dta"
di "   3. Create codebook: iecodebook export"
di "   4. Begin analysis!"
di ""
di "==============================================================="

exit
	// Ends program cleanly
