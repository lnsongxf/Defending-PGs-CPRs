*===============================================================================
* Statistical tests for "Defending public goods and common-pool resources" (De Geest & Stranlund)
* author: @lrdgeest
* last updated: 10/11/18
*===============================================================================

use full_data_labels, clear
xtset subject period

esttab m_1 m_2 using appendix_table1.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) ///
	stats(N r2_o, fmt(0 3) labels("N" "R-squared overall")) ///
	mgroups("CPR" "PG", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///	
	numbers nodepvars mlabels("Allocation" "Cooperation" "Allocation" "Cooperation") booktabs ///
	drop(1.theft) ///
	label legend  ///
	collabels(none) ///
	varlabels(_cons Constant 2.theft Theft)
	



//==============================================================================
// page 14
//==============================================================================
preserve
keep if type == 1
xtset subject period
qui eststo m_all: xtreg coop_index i.treatment if theft == 2, re cluster(group)	
test 2.treatment
foreach i in 1 2 {
	qui eststo m_`i': xtreg coop_index i.theft if treatment == `i', re cluster(group)
	test 2.theft
}
collapse (mean) coop_index, by(treatment theft group)
ranksum coop_index if theft == 2 & inlist(treatment, 1, 2), by(treatment) 
ranksum invest if treatment == 1 & inlist(theft, 1, 2), by(theft)
ranksum invest if treatment == 2 & inlist(theft, 1, 2), by(theft)
restore


//==============================================================================
// page 18
//==============================================================================
// surplus
preserve
keep if theft == 2 & type == 1
collapse (mean) surplus_value, by(treatment theft group)
ranksum surplus_value, by(treatment)
restore

// surplus loss 
preserve
keep if theft == 2 & type == 1
collapse (mean) surplus_loss, by(treatment theft group)
ranksum surplus_loss, by(treatment)
restore

// net surplus
preserve
keep if theft == 2 & type == 1
gen net_surplus = surplus_value - surplus_loss
collapse (mean) net_surplus, by(treatment theft group)
ranksum net_surplus, by(treatment)
restore

//==============================================================================
// page 19
//==============================================================================
// deterrence
preserve 
keep if type == 1 & theft == 2
gen deter_index = (assigned*3)/surplus_loss_per if surplus_loss_per > 0
replace deter_index = 1 if deter_index > 1
qui xtreg deter_index i.treatment, re cluster(group)
test 2.treatment
collapse (mean) deter_index, by(treatment theft group)
ranksum deter_index, by(treatment)
restore

// sanctions assigned
preserve
keep if type == 1 & theft == 2
xtreg points_assigned i.treatment if points_assigned > 0, re cluster(group)
test 2.treatment
collapse (mean) points_assigned, by(treatment theft group)
ranksum points_assigned, by(treatment)
restore

// payoffs
preserve
keep if type == 1 & theft == 2
qui xtreg profit i.treatment, re cluster(group)
test 2.treatment
collapse (mean) profit, by(treatment theft group)
ranksum profit, by(treatment)
restore
