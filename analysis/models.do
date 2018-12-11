*===============================================================================
* Empirical models for "Defending public goods and common-pool resources" (De Geest & Stranlund)
* author: @lrdegeest
* last updated: 11/29/18
*===============================================================================

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
// set controls
global base_controls period 2.treatment 2.treatment#c.period 
global dem_controls age gender gpa
// run models
qui eststo m1: mixed coop_index $base_controls $dem_controls || subject:, mle cluster(group)
qui estadd local group_re "No"
qui estadd local group_clustered_se "Yes"
qui eststo m2: mixed coop_index $base_controls $dem_controls || group: || subject:, mle cluster(group)
qui estadd local group_re "Yes"
qui estadd local group_clustered_se "Yes"
qui eststo m3: mixed coop_index $base_controls $dem_controls || group: || subject:, mle
qui estadd local group_re "Yes"
qui estadd local group_clustered_se "No"
// export models 
esttab m1 m2 m3 using recreate_kl2014_tab4.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("group_re Group random effects" "group_clustered_se Group clustered SEs") ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	drop(lns1_1_1:_cons lns2_1_1:_cons lnsig_e:_cons) ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		2.treatment PG 2.treatment#c.period "PG x Period")		
restore
*===============================================================================
* Same as above but for theft
*===============================================================================
preserve
keep if theft == 2 & type == 1
xtset subject period
// set controls
global base_controls period 2.treatment 2.treatment#c.period 
global dem_controls age gender gpa
// run models
qui eststo m1: mixed coop_index $base_controls $dem_controls || subject:, mle cluster(group)
qui estadd local group_re "No"
qui estadd local group_clustered_se "Yes"
qui eststo m2: mixed coop_index $base_controls $dem_controls || group: || subject:, mle cluster(group)
qui estadd local group_re "Yes"
qui estadd local group_clustered_se "Yes"
qui eststo m3: mixed coop_index $base_controls $dem_controls || group: || subject:, mle
qui estadd local group_re "Yes"
qui estadd local group_clustered_se "No"
// export models 
esttab m1 m2 m3, ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("group_re Group random effects" "group_clustered_se Group clustered SEs") ///
	numbers nodepvars nomtitles ///
	label legend  ///
	collabels(none) ///
	drop(lns1_1_1:_cons lns2_1_1:_cons lnsig_e:_cons) ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		2.treatment PG 2.treatment#c.period "PG x Period")
esttab m1 m2 m3 using pg_vs_cpr_theft.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("group_re Group random effects" "group_clustered_se Group clustered SEs") ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	drop(lns1_1_1:_cons lns2_1_1:_cons lnsig_e:_cons) ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		2.treatment PG 2.treatment#c.period "PG x Period")			
restore	
*===============================================================================
* Table 5
*===============================================================================
preserve
keep if type == 1
xtset subject period
// set controls
global base_controls period 2.theft 2.theft#c.period
global dem_controls age gender gpa
// run models
foreach i in 1 2 {	
	qui eststo m1_`i': mixed coop_index $base_controls $dem_controls || subject: if treatment == `i', mle cluster(group)
	qui estadd local group_re "No"
	qui estadd local group_clustered_se "Yes"
	qui eststo m2_`i': mixed coop_index $base_controls $dem_controls || group: || subject: if treatment == `i', mle cluster(group)
	qui estadd local group_re "Yes"
	qui estadd local group_clustered_se "Yes"
	qui eststo m3_`i': mixed coop_index $base_controls $dem_controls || group: || subject: if treatment == `i', mle
	qui estadd local group_re "Yes"
	qui estadd local group_clustered_se "No"	
}
restore
esttab m1_1 m2_1 m3_1 m1_2 m2_2 m3_2 using insiders_theft_notheft_coopindex.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("group_re Group random effects" "group_clustered_se Group clustered SEs") ///
	numbers nodepvars nomtitles booktabs ///
	mgroups("CPR" "PG", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	label legend  ///
	collabels(none) ///
	drop(lns1_1_1:_cons lns2_1_1:_cons lnsig_e:_cons) ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		2.theft Theft 2.theft#c.period "Theft x Period")
*===============================================================================
* Table 6
*===============================================================================
xtset subject period
forvalues i = 1/2 { // treatment
	di "treatment = " `i'
	forvalues j = 1/2 { // theft
		di "theft = " `j'
		preserve
		qui keep if treatment == `i' & theft == `j' & type == 1
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
gen treatment_recode = cond(treatment == 2, 1, 0)
global base_controls period i.treatment_recode##c.coop_index i.treatment_recode##c.lassigned i.treatment_recode##c.surplus_loss_per
global dem_controls age gpa i.gender
global margin_vars "coop_index lassigned surplus_loss_per"
// run models:
// 1. extensive margin
qui eststo m1: probit assigned $base_controls $dem_controls, cluster(group)
foreach v in $margin_vars {
    margins, dydx(`v') over(r.treatment_recode) vce(unconditional) 
}
qui eststo m1_margin: margins, dydx(*) vce(unconditional) post
// 2. intensive margin
qui eststo m2: tnbreg assigned $base_controls $dem_controls $interactions if assigned>0, nolog cluster(group)
foreach v in $margin_vars {
    margins, dydx(`v') over(r.treatment_recode) vce(unconditional) 
}
qui eststo m2_margin: margins, dydx(*) vce(unconditional) post
restore
// 4. table
esttab m1 m1_margin m2 m2_margin using estimate_sanctions_update.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2_p, fmt(0 3) labels("N" "Pseudo R-squared")) ///
	numbers nodepvars nomtitles booktabs collabels(none) ///
	mgroups("Extensive margin" "Intensive margin", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	drop(0.treatment_recode 1.gender 0.treatment_recode#c.lassigned  0.treatment_recode#c.coop_index 0.treatment_recode#c.surplus_loss_per) ///
	varlabels(_cons Constant age Age 2.gender Gender gpa GPA period Period ///
	1.treatment_recode  PG coop_index "Cooperation (surplus creation)" ///
	lassigned "Lagged sanctions" ///
	surplus_value "Surplus Value" surplus_loss_per "Surplus Loss (Individual)" ///
	1.treatment_recode#c.coop_index "PG X Cooperation (surplus creation)" 1.treatment_recode#c.lassigned "PG X Lagged Sanctions" 1.treatment_recode#c.surplus_loss_per "PG X Surplus loss (individual)" ///
	)
*===============================================================================
* Table 8
*===============================================================================
preserve
keep if theft == 2 & type == 2
xtset subject period
// generate vars
gen linvest = l.invest
gen delta_invest = invest - linvest
gen sanctions = points_received
gen lsanctions = l.sanctions
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
global base_controls 2.treatment lsanctions 2.treatment#c.lsanctions surplus_value period
global dem_controls age gpa gender 
// run models
foreach i in 1 2 {
	qui eststo m1_`i': mixed invest $base_controls $dem_controls || subject: if ldiff == `i',  mle cluster(group)
	qui estadd local group_re "No"
	qui estadd local group_clustered_se "Yes"
	qui eststo m2_`i': mixed invest $base_controls $dem_controls || group: || subject: if ldiff == `i', mle cluster(group)
	qui estadd local group_re "Yes"
	qui estadd local group_clustered_se "Yes"
	qui eststo m3_`i': mixed invest $base_controls $dem_controls || group: || subject: if ldiff == `i', mle 
	qui estadd local group_re "Yes"
	qui estadd local group_clustered_se "No"	
}	
// export models
esttab m1_1 m2_1 m3_1 m1_2 m2_2 m3_2 using outsider_sanctions_update.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("group_re Group random effects" "group_clustered_se Group clustered SEs") ///
	numbers nodepvars nomtitles booktabs ///
	label legend  ///
	collabels(none) ///
	mgroups("Lower or Equal Theft" "Higher Theft", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	drop(lns1_1_1:_cons lns2_1_1:_cons lnsig_e:_cons) ///
	varlabels(_cons Constant age Age gender Gender gpa GPA period Period ///
		public Public lsanctions Sanctions surplus_value "Surplus Value" ///
		2.treatment PG 2.treatment#c.lsanctions "PG x Sanctions") 
restore
