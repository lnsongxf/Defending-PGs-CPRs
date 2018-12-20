*===============================================================================
* Statistical tests for "Defending public goods and common-pool resources" (De Geest & Stranlund)
* author: @lrdgeest
* last updated: 12/13/18
*===============================================================================

use full_data_labels, clear
xtset subject period

//==============================================================================
// no theft/theft
//==============================================================================
preserve
keep if type == 1
qui eststo m_all: xtreg coop_index i.treatment if theft == 2, re cluster(group)	
test 2.treatment
foreach i in 1 2 {
	qui eststo m_`i': xtreg coop_index i.theft if treatment == `i', re cluster(group)
	di "treatment = " `i'
	test 2.theft
	di " "
}
restore

preserve
keep if type == 1 & theft == 1
qui xtreg coop_index i.treatment, re 
test 2.treatment
restore

//==============================================================================
// theft
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
// sanctions
//==============================================================================
// deterrence
preserve 
keep if type == 1 & theft == 2
gen deter_index = (assigned*3)/surplus_loss_per if surplus_loss_per > 0
replace deter_index = 1 if deter_index > 1
qui xtreg deter_index i.treatment, re cluster(group)
test 2.treatment
restore

// sanctions assigned
preserve
keep if type == 1 & theft == 2
qui xtreg points_assigned i.treatment if points_assigned > 0, re cluster(group)
test 2.treatment
qui xtreg points_assigned i.treatment, re cluster(group)
test 2.treatment
restore

//==============================================================================
// payoffs
//==============================================================================
preserve
keep if type == 1 & theft == 2
qui xtreg profit i.treatment, re cluster(group)
test 2.treatment
restore
