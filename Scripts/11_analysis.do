/****************************************************************************

	Project:        [PROJECT NAME]
	Description:    Sample analysis - descriptive statistics and regressions

	Created by:     [YOUR NAME]
	Date created:   [DATE]
	Last updated:   [DATE]

****************************************************************************/

*---------------------------------------------------*
* 11.1 Setup
*---------------------------------------------------*

* Load analysis dataset
use "${clean}/analysis_dataset.dta", clear

* Set output directory for results
global output "${results}/tables"
cap mkdir "${output}"


*---------------------------------------------------*
* 11.2 Basic descriptive statistics
*---------------------------------------------------*

* Summary statistics for continuous variables
summarize age income consumption_pc, detail
	// detail = shows percentiles, skewness, kurtosis

* Store summary stats in matrix for export
tabstat age income consumption_pc, ///
	stats(n mean sd min p25 p50 p75 max) ///
	columns(statistics) save
	// save = stores results in r(StatTotal)

matrix sumstats = r(StatTotal)'
	// Transpose for better layout

* Frequency tables for categorical variables
tab gender
tab educ_level
tab wealth_quintile

* Two-way tabulation
tab gender educ_level, row
	// row = row percentages
	// Shows education distribution by gender

* Cross-tabulation with chi-square test
tab gender employed, chi2
	// chi2 = Pearson chi-square test
	// Tests independence of gender and employment


*---------------------------------------------------*
* 11.3 Group comparisons
*---------------------------------------------------*

* Compare means across groups
tabstat consumption_pc, by(wealth_quintile) stats(n mean sd)

* T-test for two groups
ttest consumption_pc, by(female)
	// Tests: Is mean consumption different for men vs women?

* One-way ANOVA for multiple groups
oneway consumption_pc educ_level, tabulate
	// Tests: Does consumption differ by education level?


*---------------------------------------------------*
* 11.4 Correlation analysis
*---------------------------------------------------*

* Pairwise correlations
correlate age income consumption_pc asset_index_pca
	// Shows correlation matrix

pwcorr age income consumption_pc asset_index_pca, sig star(.05)
	// sig = shows p-values
	// star(.05) = marks significant correlations


*---------------------------------------------------*
* 11.5 Basic OLS regression
*---------------------------------------------------*

* Simple regression
reg consumption_pc income
	// consumption = f(income)

* Store results
estimates store model1

* Multiple regression
reg consumption_pc income age female urban educ_level
	// Add demographic controls

estimates store model2

* Regression with robust standard errors
reg consumption_pc income age female urban i.educ_level, robust
	// robust = heteroskedasticity-robust SEs
	// i.educ_level = treat as categorical (creates dummies)

estimates store model3


*---------------------------------------------------*
* 11.6 Export regression results using putexcel
*---------------------------------------------------*

* Setup Excel file
putexcel set "${output}/regression_results.xlsx", sheet("Main Results") replace

* Add headers
putexcel A1 = "Regression Results: Determinants of Per Capita Consumption"
putexcel A3 = "Variable"
putexcel B3 = "Model 1"
putexcel C3 = "Model 2"
putexcel D3 = "Model 3"

* Export Model 1 results
estimates restore model1

putexcel A5 = "Income"
putexcel B5 = _b[income], nformat(0.000)
putexcel B6 = _se[income], nformat((0.000))
	// _b = coefficient, _se = standard error

putexcel A8 = "Constant"
putexcel B8 = _b[_cons], nformat(0.000)
putexcel B9 = _se[_cons], nformat((0.000))

putexcel A11 = "R-squared"
putexcel B11 = e(r2), nformat(0.000)

putexcel A12 = "N"
putexcel B12 = e(N), nformat(#,##0)

* Export Model 2 results
estimates restore model2

putexcel C5 = _b[income], nformat(0.000)
putexcel C6 = _se[income], nformat((0.000))

putexcel A14 = "Age"
putexcel C14 = _b[age], nformat(0.000)
putexcel C15 = _se[age], nformat((0.000))

putexcel A17 = "Female"
putexcel C17 = _b[female], nformat(0.000)
putexcel C18 = _se[female], nformat((0.000))

putexcel A20 = "Urban"
putexcel C20 = _b[urban], nformat(0.000)
putexcel C21 = _se[urban], nformat((0.000))

putexcel A23 = "Education level"
putexcel C23 = _b[educ_level], nformat(0.000)
putexcel C24 = _se[educ_level], nformat((0.000))

putexcel C8 = _b[_cons], nformat(0.000)
putexcel C9 = _se[_cons], nformat((0.000))

putexcel C11 = e(r2), nformat(0.000)
putexcel C12 = e(N), nformat(#,##0)

* Export Model 3 results (with categorical education)
estimates restore model3

putexcel D5 = _b[income], nformat(0.000)
putexcel D6 = _se[income], nformat((0.000))

putexcel D14 = _b[age], nformat(0.000)
putexcel D15 = _se[age], nformat((0.000))

putexcel D17 = _b[female], nformat(0.000)
putexcel D18 = _se[female], nformat((0.000))

putexcel D20 = _b[urban], nformat(0.000)
putexcel D21 = _se[urban], nformat((0.000))

putexcel A26 = "Education: Secondary"
putexcel D26 = _b[2.educ_level], nformat(0.000)
putexcel D27 = _se[2.educ_level], nformat((0.000))

putexcel A29 = "Education: Tertiary"
putexcel D29 = _b[3.educ_level], nformat(0.000)
putexcel D30 = _se[3.educ_level], nformat((0.000))

putexcel D8 = _b[_cons], nformat(0.000)
putexcel D9 = _se[_cons], nformat((0.000))

putexcel D11 = e(r2), nformat(0.000)
putexcel D12 = e(N), nformat(#,##0)

* Add note
putexcel A32 = "Note: Standard errors in parentheses. Model 3 uses robust SEs."


*---------------------------------------------------*
* 11.7 Alternative: Export using matrices
*---------------------------------------------------*

* This approach is more efficient for many coefficients

estimates restore model3

* Create matrix of results
matrix results = r(table)'
	// r(table) contains coefficients, SEs, p-values, CIs

* Export matrix to new sheet
putexcel set "${output}/regression_results.xlsx", sheet("Full Model 3") modify
putexcel A1 = "Full Model 3 Results"
putexcel A3 = matrix(results), names nformat(0.0000)


*---------------------------------------------------*
* 11.8 Export summary statistics table
*---------------------------------------------------*

putexcel set "${output}/regression_results.xlsx", sheet("Summary Stats") modify

putexcel A1 = "Summary Statistics"
putexcel A3 = matrix(sumstats), names nformat(0.00)


*---------------------------------------------------*
* 11.9 Logistic regression example
*---------------------------------------------------*

* Binary outcome: employment status
logit employed income age female urban i.educ_level, or
	// or = odds ratios (easier to interpret)
	// Odds ratio > 1 = positive effect
	// Odds ratio < 1 = negative effect

estimates store logit1

* Export logit results
putexcel set "${output}/regression_results.xlsx", sheet("Logit Results") modify

putexcel A1 = "Logistic Regression: Determinants of Employment"
putexcel A3 = "Variable"
putexcel B3 = "Odds Ratio"
putexcel C3 = "Std. Error"
putexcel D3 = "P-value"

local row = 5
foreach var in income age female urban {
	putexcel A`row' = "`var'"
	putexcel B`row' = exp(_b[`var']), nformat(0.000)
	putexcel C`row' = _se[`var'], nformat(0.000)

	* Calculate p-value
	local z = _b[`var'] / _se[`var']
	local p = 2 * (1 - normal(abs(`z')))
	putexcel D`row' = `p', nformat(0.000)

	local row = `row' + 1
}

putexcel A`row' = "Education: Secondary"
putexcel B`row' = exp(_b[2.educ_level]), nformat(0.000)
local row = `row' + 1

putexcel A`row' = "Education: Tertiary"
putexcel B`row' = exp(_b[3.educ_level]), nformat(0.000)
local row = `row' + 2

putexcel A`row' = "Pseudo R-squared"
putexcel B`row' = e(r2_p), nformat(0.000)
local row = `row' + 1

putexcel A`row' = "N"
putexcel B`row' = e(N), nformat(#,##0)


*---------------------------------------------------*
* 11.10 Close and display results location
*---------------------------------------------------*

di _n "Results exported to: ${output}/regression_results.xlsx"
di "Sheets: Main Results, Full Model 3, Summary Stats, Logit Results"
