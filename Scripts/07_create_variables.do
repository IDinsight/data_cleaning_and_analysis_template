/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Create and transform variables for analysis

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

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
	// Old categories 0,1,2 -> New category 1 "Primary or less"
	// Old categories 3,4 -> New category 2 "Secondary"
	// Old categories 5,6,7,8 -> New category 3 "Tertiary"
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
	// Example: item1=2, item2=3, item3=1 -> total=6

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
