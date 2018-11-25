*===============================================================================
* standard deviation over time
* author: @lrdgeest
* last updated: 11/19/18
*===============================================================================
use full_data_labels, clear

// individual
preserve
keep if type == 1
collapse (sd) sd_invest=invest, by(treatment theft period)
forvalues i = 1/2 {
	local t : label treatment `i'
	tw	(line sd_invest period if treatment == `i', sort), ///
		by(theft, note("") title(`t')) /// 
		xlabel(1(2)15) ylabel(0(4)16) ///
		xtitle("Period") ytitle("Standard deviation of allocation") /// 
		name(sd_ind_`i', replace) nodraw
}	
gr combine sd_ind_1 sd_ind_2, cols(1)
forvalues i = 1/2 {
	qui eststo  m`i': reg sd_invest i.theft##c.period if treatment == `i', robust
}
esttab m1 m2 using stdev.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N, fmt(0) labels("N")) ///
	nonumbers nodepvars mtitles("CPR" "PG") ///
	label legend  ///
	collabels(none) ///
	drop(1.theft 1.theft#c.period) ///
	varlabels(_cons Constant period Period 2.theft Theft 2.theft#c.period "Theft X Period")
restore	


// group
preserve
keep if type == 1
collapse (sd) sd_invest=invest, by(treatment group theft period)
gen group_n = group - (treatment*1000 + theft*100 + 10)
// cpr
tw 	line sd_invest period if treatment == 1 & theft == 1, sort by(group_n, note("") title("CPR, No Theft")) ///
	xtitle("Period") ytitle("SD(allocation)") ylabel(0(10)30) /// 
	name(cpr1, replace) nodraw
tw 	line sd_invest period if treatment == 1 & theft == 2, sort by(group_n, note("") title("CPR, Theft")) ///
	xtitle("Period") ytitle("SD(allocation)") ylabel(0(10)30) ///
	name(cpr2, replace) nodraw
// pg
tw 	line sd_invest period if treatment == 2 & theft == 1, sort by(group_n, note("") title("PG, No Theft")) ///
	xtitle("Period") ytitle("SD(allocation)") ylabel(0(10)30) ///
	name(pg1, replace) nodraw
tw	line sd_invest period if treatment == 2 & theft == 2, sort by(group_n, note("") title("PG, Theft")) ///
	xtitle("Period") ytitle("SD(allocation)") ylabel(0(10)30) ///
	name(pg2, replace) nodraw
// combined
gr combine cpr1 cpr2 pg1 pg2, ycommon
restore	





	


