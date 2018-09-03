*===============================================================================
* Empirical figures for "Defending public goods and common-pool resources" (De Geest & Stranlund)
* author: @lrdgeest
* last updated: 9/3/18
*===============================================================================

use full_data_labels, clear 

*===============================================================================
* Figure 4
*===============================================================================
preserve
keep if type == 1
collapse (mean) invest coop_index, by(treatment theft period)
tw	(connected invest period if theft == 1 & treatment == 1, sort) ///
	(connected invest period if theft == 1 & treatment == 2, sort m(Sh)) ///
	(connected invest period if theft == 2 & treatment == 1, sort m(O)) ///
	(connected invest period if theft == 2 & treatment == 2, sort m(S)), ///
	xlabel(1(2)15) ylabel(0(5)50, nogrid) ytitle("Average allocation (CPR & PG)") xtitle("Period") ///
	legend(cols(1) order(1 "CPR No theft" 2 "PG No theft" 3  "CPR theft" 4 "PG Theft") ring(0) position(8)) ///
	subtitle("{bf:A}", ring(0) pos(10) size(large)) ///	
	name(invest, replace) nodraw
tw	(connected coop_index period if theft == 1 & treatment == 1, sort) ///
	(connected coop_index period if theft == 2 & treatment == 1, sort m(O)), ///
	xlabel(1(2)15) ylabel(0(0.2)1, nogrid) ytitle("Average cooperation (CPR)") xtitle("Period") ///
	legend(cols(1) order(1 "CPR No theft" 2 "CPR theft") ring(0) position(8)) ///
	subtitle("{bf:B}", ring(0) pos(10) size(large)) ///
	name(coop_cpr, replace) nodraw
tw	(connected coop_index period if theft == 1 & treatment == 2, sort m(Sh)) ///
	(connected coop_index period if theft == 2 & treatment == 2, sort m(S)), ///
	xlabel(1(2)15) ylabel(0(0.2)1, nogrid) ytitle("Average cooperation (PG)") xtitle("Period") ///
	legend(cols(1) order(1 "PG No theft" 2 "PG Theft") ring(0) position(8)) ///
	subtitle("{bf:C}", ring(0) pos(10) size(large)) ///
	name(coop_pg, replace) nodraw	
graph combine invest coop_cpr coop_pg, cols(3) name(p)
graph display p, xsize(9.0) ysize(4.0)
restore
*===============================================================================
* Figure 5
*===============================================================================
preserve
gen group_common = group - (treatment*1000 + 100*theft + 10*communication)		 
keep if type == 1
collapse (mean) coop_index, by(treatment theft group_common)
stripplot coop_index, over(theft) by(treatment, note("")) ///
	box(barw(0.1)) pct(0.1) boffset(-0.15) ///
	mcolor(gray) msymbol(circle) ///
	vertical stack height(0.4) ylabel(.1(.1).5,nogrid) ///
	refline(lcolor(black) lwidth(thick)) centre ///
	ytitle("Average insider cooperation (group)") xtitle("")
restore			 
*===============================================================================
* Figure 6
*===============================================================================
preserve
keep if theft == 2 & type == 1
// gen net surplus value
gen net_surplus_value = surplus_value - surplus_loss
// gen sanctions
gen individual_sanctions = assigned*3
egen group_sanctions = sum(individual_sanctions), by(treatment group period)
collapse (mean) invest=invest /// 
				surplus_value=surplus_value ///
				net_surplus_value=net_surplus_value ///
				surplus_loss=surplus_loss ///
				group_sanctions = group_sanctions, ///
			by(treatment period)
gen surplus_loss_share = (surplus_loss/surplus_value)*100
gen deterrence = (group_sanctions/surplus_loss)*100
// average surplus
tw	(connected surplus_value period if treatment == 1, sort) ///
	(connected surplus_value period if treatment == 2, sort), ///
	legend(cols(2) order(1 "CPR Theft" 2 "PG Theft")) ///
	xlabel(1(2)15) ylabel(0(75)450,nogrid) ///
	ytitle("Average surplus ({c $|}ED)") xtitle("Period") ///
	subtitle("{bf:A}", ring(0) pos(10) size(large)) ///
	name(surplus, replace) nodraw
// average net surplus	
tw	(connected net_surplus_value period if treatment == 1, sort) ///
	(connected net_surplus_value period if treatment == 2, sort), ///
	legend(cols(2) order(1 "CPR Theft" 2 "PG Theft")) ///
	xlabel(1(2)15) ylabel(0(75)450,nogrid) ///
	ytitle("Average surplus net theft ({c $|}ED)") xtitle("Period") ///
	subtitle("{bf:B}", ring(0) pos(10) size(large)) ///
	name(net_surplus, replace) nodraw	
// average surplus net theft	
tw	(connected surplus_loss_share period if treatment == 1, sort) ///
	(connected surplus_loss_share period if treatment == 2, sort), ///
	xlabel(1(2)15) ylabel(0(10)50, nogrid) ///
	ytitle("Average surplus lost to theft (percent)") xtitle("Period") ///
	subtitle("{bf:C}", ring(0) pos(10) size(large)) ///
	name(loss, replace) nodraw
// average deterrence	
su deterrence
tw	(connected deterrence period if treatment == 1, sort) ///
	(connected deterrence period if treatment == 2, sort), ///
	xlabel(1(2)15) ylabel(0(25)200,nogrid) ///
	ytitle("Average deterrence (percent)") xtitle("Period") ///
	yline(100, lcol(black) lpattern(dash)) ///
	subtitle("{bf:D}", ring(0) pos(10) size(large)) ///
	name(deterrence, replace) nodraw	
// combined plot	
grc1leg surplus net_surplus loss deterrence, legendfrom(surplus) cols(2)
restore	
