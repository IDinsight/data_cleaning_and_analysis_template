/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    De-identification and data protection

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

	IMPORTANCE: CRITICAL for ethics and legal compliance

****************************************************************************/

/*==================================================================
	What is PII (Personally Identifiable Information)?

	DIRECT IDENTIFIERS (can identify person directly):
	- Names (respondent, household head, children)
	- Phone numbers
	- Email addresses
	- National ID numbers
	- Exact GPS coordinates (can locate house)
	- Photos with faces
	- Voice recordings

	INDIRECT IDENTIFIERS (combination can identify):
	- Age + Gender + Village (if village is small)
	- Rare occupation + Location
	- Unique characteristics mentioned

	WHY REMOVE?
	- Protect respondent privacy
	- Comply with ethics (IRB requirements)
	- Comply with laws (GDPR, local regulations)
	- Prevent misuse of data
	- Enable data sharing
==================================================================*/

*---------------------------------------------------*
* 9.1 Separate PII data (save separately, encrypted)
*---------------------------------------------------*

preserve
	// SAVES: Current dataset state (can restore later)
	// WHY: So we can extract PII without losing main data

	* Keep only ID and PII variables
	keep unique_id respondent_name household_head_name ///
		phone_number national_id ///
		gps_latitude gps_longitude exact_address ///
		child_name_1 child_name_2
		// CUSTOMIZE: Add all PII variables in your data

	* Save PII dataset in encrypted location
	save "$clean_pii/survey_pii_`current_date'.dta", replace
		// CRITICAL: This folder must be encrypted/password-protected
		// ACCESS: Only authorized team members
		// SHARING: Never share this file publicly

restore
	// RETURNS: To full dataset (with all variables)


*---------------------------------------------------*
* 9.2 Remove PII from main dataset
*---------------------------------------------------*

* Drop direct identifiers
drop respondent_name household_head_name ///
	phone_number national_id email ///
	child_name_1 child_name_2 child_name_3 ///
	enum_name enum_phone ///
	exact_address street_address
	// CUSTOMIZE: Drop all PII variables in your dataset
	//
	// IMPORTANT: Double-check you're not dropping:
	// - enum_id (useful for analysis, not identifying if coded)
	// - unique_id (needed, not PII if properly coded)

* Mask indirect identifiers (if needed)

** Option 1: Round GPS to broader area
gen gps_lat_approx = round(gps_latitude, 0.01)
gen gps_lon_approx = round(gps_longitude, 0.01)
	// Rounds to ~1km area instead of exact location
	// Still useful for mapping, but not pinpoint house

drop gps_latitude gps_longitude

** Option 2: Drop small geographic units
* drop village_name
	// If village is small, combination of village + age + gender
	// might identify respondent
	// Keep only district level for small samples


*---------------------------------------------------*
* 9.3 Verify de-identification complete
*---------------------------------------------------*

* Check no name/phone variables remain
ds *name* *phone* *address*, not
	// Lists all variables NOT containing these words
	// If returns complete list = good!
	// If error "no variables" = still have PII, check again

* Document de-identification
note: "PII removed on `current_date'"
note: "PII stored separately in encrypted folder: $clean_pii"
note: "This dataset is de-identified and safe to share with analysts"
