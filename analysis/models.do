*===============================================================================
* Empirical models for "Defending public goods and common-pool resources" (De Geest & Stranlund)
* author: @lrdegeest
* last updated: 11/2/18
*===============================================================================

cd /Users/LawrenceDeGeest/Desktop/notebook/research/Defending-PGs-CPRs/data
use full_data_labels, clear

*===============================================================================
* Table 3 
*===============================================================================
preserve
keep if type == 1
bysort treatment: tabstat invest coop profit, by(theft) stat(mean sd) nototal
restore
*===============================================================================
* Table 4 
*===============================================================================
preserve
keep if theft == 1
xtset subject period
gen public = cond(treatment == 2, 1, 0)
// set controls
global base_controls period i.public 1.public#c.period 
global dem_controls age gender gpa
// run models
qui eststo m1: xtreg coop_index $base_controls, re
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
qui eststo m2: xtreg coop_index $base_controls $dem_controls, re 
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
qui eststo m3: xtreg coop_index $base_controls $dem_controls i.group, re 
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
// export models 
esttab m1 m2 m3  using recreate_kl2014_tab4.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_o Rho, fmt(0 3 3) labels("N" "R-squared overall" "Rho")) ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	indicate("Group fixed effects = *group") ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		1.public Public 1.public#c.period "Public x Period")
restore	
*===============================================================================
* Same as above but for theft
*===============================================================================
preserve
keep if theft == 2 & type == 1
xtset subject period
gen public = cond(treatment == 2, 1, 0)
// set controls
global base_controls period i.public 1.public#c.period 
global dem_controls age gender gpa
// run models
qui eststo m1: xtreg coop_index $base_controls, re
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
qui eststo m2: xtreg coop_index $base_controls $dem_controls, re 
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
qui eststo m3: xtreg coop_index $base_controls $dem_controls i.group, re 
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
// export models 
esttab m1 m2 m3  using pg_vs_cpr_theft.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_o Rho, fmt(0 3 3) labels("N" "R-squared overall" "Rho")) ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	indicate("Group fixed effects = *group") ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		1.public Public 1.public#c.period "Public x Period")
restore	
*===============================================================================
* Table 5
*===============================================================================
preserve
keep if type == 1
xtset subject period
// set controls
global base_controls period theft 2.theft#c.period
global dem_controls age gender gpa
// run models
foreach i in 1 2 {	
	qui eststo m1_`i': xtreg coop_index $base_controls if treatment == `i', re cluster(group)
	estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
	qui eststo m2_`i': xtreg coop_index $base_controls $dem_controls if treatment == `i', re cluster(group)
	estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
	qui eststo m3_`i': xtreg coop_index $base_controls $dem_controls i.group if treatment == `i', re cluster(group)
	estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]	
}
restore
// re-run fully-specified model for PG but drop smallest group
preserve
xtset subject period
keep if treatment == 2
drop if group == 2111
qui eststo m3_3: xtreg coop_index $base_controls $dem_controls i.group, re cluster(group)
estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]	
restore
// export models 
esttab m1_1 m2_1 m3_1 m1_2 m2_2 m3_2 m3_3  using insiders_theft_notheft_coopindex.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_o Rho, fmt(0 3 3) labels("N" "R-squared overall" "Rho")) ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("CPR" "PG", pattern(1 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	indicate("Group fixed effects = *group") ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		2.theft Theft 2.theft#c.period "Theft x Period")
*===============================================================================
* Table 6
*===============================================================================
use full_data_labels, clear
preserve
xtset subject period
forvalues i = 1/2 { // treatment
	di "treatment = " `i'
	forvalues j = 1/2 { // theft
		di "theft = " `j'
		preserve
		qui keep if treatment == `i' & theft == `j'
		qui xtreg invest i.group i.period, re cluster(group)
		predict resid, e
		gen d = abs(resid)
		qui xtreg d i.group, re 
		di "Test:" 
		di "Chi2 = " e(chi2) " "  "p-val = " e(p) " " "N = " e(N)
		di " "
		restore
	}
}		
restore
*===============================================================================
* Table 7
*===============================================================================
preserve
keep if theft == 2 & type == 1
xtset subject period
gen lassigned = l.assigned
// confirm overdispersion
tabstat assigned, by(treatment) stat(mean sd) nototal
// set controls
global base_controls i.treatment period coop_index lassigned surplus_loss_per
global dem_controls age gpa i.gender
global treatment_controls period coop_index lassigned surplus_loss_per
// run models
qui eststo m1: probit assigned $base_controls $dem_controls, nolog cluster(group)
qui eststo m1_margin: margins, dydx(*) post
qui eststo m2: tnbreg assigned $base_controls $dem_controls if assigned>0, nolog cluster(group)
qui eststo m2_margin: margins, dydx(*) post
restore
// export models
esttab m1 m1_margin m2 m2_margin using estimate_sanctions.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N chi2 r2_p, fmt(0 3 3) labels("N" "Wald Chi-squared" "Pseudo R-squared")) ///
	numbers nodepvars nomtitles booktabs collabels(none) ///
	mgroups("Intensive margin" "Extensive margin", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	drop(1.treatment 1.gender) ///
	varlabels(_cons Constant age Age 2.gender Gender gpa GPA period Period ///
		2.treatment PG coop_index "Cooperation (Allocation)" ///
		lassigned "Sanctions in {it:t-1}" ///
		surplus_value "Surplus Value" surplus_loss_per "Surplus Loss (Individual)")
*=======================
// update: reviwer's interaction tests
*=======================
/// original
qui eststo m1: probit assigned $base_controls $dem_controls, nolog cluster(group)
qui eststo m1_margin: margins, dydx(*) vce(unconditional)
qui eststo m2: tnbreg assigned $base_controls $dem_controls if assigned>0, nolog cluster(group)
qui eststo m2_margin: margins, dydx(*) vce(unconditional)
/// new
qui eststo m3: probit assigned $base_controls $dem_controls c.coop_index#c.lassigned, nolog cluster(group)
qui margins, dydx(coop_index) at(lassigned =(0(2)20)) vce(unconditional)
marginsplot, name(em, replace) title("Extensive margin") xtitle("Lagged sanctions") nodraw
qui eststo m3_margin: margins, dydx(*) vce(unconditional)
qui eststo m4: tnbreg assigned $base_controls $dem_controls c.coop_index#c.lassigned if assigned>0, nolog cluster(group)
qui margins, dydx(coop_index) at(lassigned =(0(2)20)) vce(unconditional)
marginsplot, name(im, replace) title ("Intensive margin") xtitle("Lagged sanctions") nodraw
qui eststo m4_margin: margins, dydx(*) vce(unconditional)
// export models
esttab m1 m3 m1_margin m3_margin m2 m4 m2_margin m4_margin using estimate_sanctions_update.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N chi2 r2_p, fmt(0 3 3) labels("N" "Wald Chi-squared" "Pseudo R-squared")) ///
	numbers nodepvars nomtitles booktabs collabels(none) ///
	mgroups("Extensive margin" "Extensive margin" "Intensive margin" "Intensive margin", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	drop(1.treatment 1.gender) ///
	varlabels(_cons Constant age Age 2.gender Gender gpa GPA period Period ///
		2.treatment PG coop_index "Cooperation (surplus creation)" ///
		lassigned "Sanctions in t-1" ///
		c.coop_index#c.lassigned "Cooperation (surplus creation) X Sanctions in t-1" ///
		surplus_value "Surplus Value" surplus_loss_per "Surplus Loss (Individual)" ///
		2.treatment#c.coop_index "PG X Cooperation" 2.treatment#c.lassigned "Lagged Sanctions" ///
		)
gr combine em im 
restore


esttab m1 m3 m1_margin m3_margin m2 m4 m2_margin m4_margin, mgroups("Extensive margin" "Intensive margin", pattern(1 0 0))
*===============================================================================
* Table 8
*===============================================================================
preserve
use full_data_labels, clear
keep if theft == 2 & type == 2
xtset subject period
// generate vars
gen linvest = l.invest
gen delta_invest = invest - linvest
gen sanctions = points_received
gen lsanctions = l.sanctions
gen public = cond(treatment == 2, 1, 0)
// gen diff var
gen diff = cond(invest>(sum_invest_g2-invest), 2, 0)
replace diff = 1 if invest < (sum_invest_g2-invest)
replace diff = 0 if diff == .
graph bar (sum) sanctions, over(diff) by(treatment, note("")) blabel(total) asyvars ///
	ytitle("Total Sanctions") ylabel(,nogrid) ///
	legend(cols(1) order(1 "Equal" 2 "Less theft than other outsider" 3 "More theft than other outsider"))
// the majority of sanctions go to highest theft outsider
// set diff == 1 for less than or equal to thievers 
replace diff = 1 if diff == 0	
gen ldiff = l.diff
// set controls
global base_controls public lsanctions 1.public#c.lsanctions surplus_value period
global dem_controls age gpa gender 
// run models
foreach i in 1 2 {
	qui eststo m1_`i': xtreg invest $base_controls if ldiff == `i', re cluster(group)
	qui estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
	qui eststo m2_`i': xtreg invest $base_controls $dem_controls if ldiff == `i', re cluster(group)
	qui estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
	qui eststo m3_`i': xtreg invest $base_controls $dem_controls i.group if ldiff == `i', re cluster(group)
	qui estadd scalar Rho = e(sigma_u)^2/[e(sigma_u)^2 + e(sigma_e)^2]
}	
// export models
esttab m1_1 m2_1 m3_1 m1_2 m2_2 m3_2 using estimate_sanctions_update.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_o Rho, fmt(0 3 3) labels("N" "R-squared overall" "Rho")) ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	mgroups("Lower or Equal Theft" "Higher Theft", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	indicate("Group fixed effects = *group") ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		public Public lsanctions Sanctions surplus_value "Surplus Value" ///
		1.public Public 1.public#c.lsanctions "Public x Sanctions") 		
restore
