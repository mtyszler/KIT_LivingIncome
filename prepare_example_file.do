*use "Cocoa_Livelihoods_clean_LI.dta", replace

gen benchmark = .
label variable benchmark "Value of the Living Income Benchmark for this group"
replace benchmark = 4742 if grouping == 1
replace benchmark = 5123 if grouping == 2
replace benchmark = 4001 if grouping == 3

gen food_value = 450 
label variable food_value "Estimated value of crops produced and consumed at home"

drop start-enumerator_code
drop region_comparable-resp_fname
drop hhmem_number_check
drop male_adults_over_65-head_age_cat
drop head_education-incsource_biggest2
drop crops_all_produced_1-chili_hh

keep if cocoa_hh
drop cocoa_hh-cocoa_land_used_ha
drop li_cocoa_costs_usdhh_2018-li_cocoa_transport_hh_n_hh
drop cocoa_land_owned-cocoa_prod_season2_kgha
drop cocoa_profit1_usdha-version_source
drop migrant-li_char_acceptable_categ
drop li_cocoa_landclear_hi_n_ha-li_cocoa_inputs_usdha
drop cocoa_revenue_usdha_2018-li_cocoa_hi_lab_usdha_2018
drop hh_income_perc_othercrops-hh_income_perc_other

drop cocoa_revenue_usdha
drop cocoa_hh_mostimp

save "kitli_exampledata.dta", replace
