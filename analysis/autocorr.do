*===============================================================================
* Autocorrelation stats for "Defending public goods and common-pool resources" (De Geest & Stranlund)
* author: @lrdgeest
* last updated: 01/08/19
*===============================================================================

capture program drop group_autocorr
program define group_autocorr
	version 15
	syntax [if]
	keep if type == 1
	collapse (sum) invest `if', by(treatment theft group period)
	xtset group period
	gen linvest = l.invest
	qui tab group
	matrix corrs=J(r(r),5,.)
	qui levelsof treatment, local(treatments)
	qui levelsof theft, local(thefts)
	local i = 1
	foreach t in `treatments'{
		foreach th in `thefts' {
		preserve
		keep if treatment == `t' & theft == `th'
		qui levelsof group, local(groups)
			foreach g in `groups'{
				local g_simple = `g' - (1000*`t' + 100*`th' + 10)
				qui pwcorr invest linvest if group == `g', sig 
				matrix s=r(sig)
				matrix corrs[`i', 1] = `t'
				matrix corrs[`i', 2] = `th'
				matrix corrs[`i', 3] = `g_simple'
				matrix corrs[`i', 4] = r(rho)
				matrix corrs[`i', 5] = s[2,1]
				local ++i
			}
		restore
		}
	}
	matrix colnames corrs = treatment theft group alpha p-value
	esttab matrix(corrs)
end

cd "/Users/LawrenceDeGeest/Desktop/notebook/research/Defending-PGs-CPRs/data"

// all periods
use full_data_labels, clear
group_autocorr

// periods 7-15
use full_data_labels, clear
group_autocorr if period > 6
