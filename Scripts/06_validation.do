/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Data validation and quality checks

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

	NOTE: These checks can also be done during HFCs

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
