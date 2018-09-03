use full_data, clear
label define treatment 1 "CPR" 2 "PG"
label values treatment treatment
label define theft 1 "No theft" 2 "Theft"
label values theft theft
label drop gender
label define gender 1 "Male" 2 "Female"
label values gender gender
sort treatment theft communication subject group period
save "full_data_labels", replace
