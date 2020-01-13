* Load data
use ..\data_cleaned, replace
remove_outliers prod_total_last_kg

local CEDI_USD = 0.20359 // Jan 15th, 2019

* drop "respondent" from varname
rename p1_respondent_* p1_*
label variable hhmem_number "Number of household members"
label variable male_adults_15_65 "Males, 15 to 65 years old"
label variable male_adults_over_65 "Males over 65 years old"
label variable female_adults_over_65 "Females over 65 years old"
label variable female_adults_15_65 "Females, 15 to 65 years old"
label variable male_children_5_14 "Males, 5 to 14 years old"
label variable female_children_5_14 "Females, 5 to 14 years old"
label variable male_children_0_4 "Males, 0 to 4 years old"
label variable female_children_0_4 "Females, 0 to 4 years old"


/********** total hh income
gen grouping = .
replace grouping = 1 if head_gender == 1 & cocoa_land_used_morethan5_ha <=4 & cocoa_land_used_morethan5_ha>0
replace grouping = 2 if head_gender == 1 & cocoa_land_used_morethan5_ha >4 & cocoa_land_used_morethan5_ha!=.
replace grouping = 3 if head_gender == 2
label define lblGROUPS 1 "Male-headed, typical" 2 "Male-headed, large" 3 "Female-headed"
label values grouping lblGROUPS

**
gen grouping_alt = .
replace grouping_alt = 2 if head_gender == 1 & cocoa_land_used_morethan5_ha <=4 & cocoa_land_used_morethan5_ha>0
replace grouping_alt = 3 if head_gender == 1 & cocoa_land_used_morethan5_ha >4 & cocoa_land_used_morethan5_ha!=.
replace grouping_alt = 1 if head_gender == 2
label define lblGROUPS_ALT 2 "Male-headed, typical" 3 "Male-headed, large" 1 "Female-headed"
label values grouping_alt lblGROUPS_ALT
*/

** convert labour costs to USD
foreach var of varlist landclear_hh_costha landclear_hired_costha landclear_lab_costha landclear_com_costha landprep_hh_costha landprep_hired_costha landprep_lab_costha landprep_com_costha planting_hh_costha planting_hired_costha planting_lab_costha planting_com_costha gfertilizer_hh_costha gfertilizer_hired_costha gfertilizer_lab_costha gfertilizer_com_costha lfertilizer_hh_costha lfertilizer_hired_costha lfertilizer_lab_costha lfertilizer_com_costha manure_compost_hh_costha manure_compost_hired_costha manure_compost_lab_costha manure_compost_com_costha herbicide_hh_costha herbicide_hired_costha herbicide_lab_costha herbicide_com_costha pesticide_hh_costha pesticide_hired_costha pesticide_lab_costha pesticide_com_costha fungicide_hh_costha fungicide_hired_costha fungicide_lab_costha fungicide_com_costha weed1_hh_costha weed1_hired_costha weed1_lab_costha weed1_com_costha weed2_hh_costha weed2_hired_costha weed2_lab_costha weed2_com_costha weed3_hh_costha weed3_hired_costha weed3_lab_costha weed3_com_costha weed4_hh_costha weed4_hired_costha weed4_lab_costha weed4_com_costha weed_lab_costha weed_hired_costha pruning_hh_costha pruning_hired_costha pruning_lab_costha pruning_com_costha harvest1_hh_costha harvest1_hired_costha harvest1_lab_costha harvest1_com_costha harvest2_hh_costha harvest2_hired_costha harvest2_lab_costha harvest2_com_costha harvest_lab_costha harvest_hired_costha podbreak1_hh_costha podbreak1_hired_costha podbreak1_lab_costha podbreak1_com_costha podbreak2_hh_costha podbreak2_hired_costha podbreak2_lab_costha podbreak2_com_costha podbreak_lab_costha podbreak_hired_costha ferment1_hh_costha ferment1_hired_costha ferment1_lab_costha ferment1_com_costha ferment2_hh_costha ferment2_hired_costha ferment2_lab_costha ferment2_com_costha ferment_lab_costha ferment_hired_costha dry1_hh_costha dry1_hired_costha dry1_lab_costha dry1_com_costha dry2_hh_costha dry2_hired_costha dry2_lab_costha dry2_com_costha dry_lab_costha dry_hired_costha transport1_hh_costha transport1_hired_costha transport1_lab_costha transport1_com_costha transport2_hh_costha transport2_hired_costha transport2_lab_costha transport2_com_costha transport_lab_costha transport_hired_costha {
	local newvar_name = regexr("`var'","cost","usd")
	gen `newvar_name' = `var'* `CEDI_USD'
	note `newvar_name': converted uinsg exchange rate of `CEDI_USD' USD per CEDI_USD
	order `newvar_name', after( `var')

	local original_label: variable label `var'
	local new_label = regexr("`original_label'","CEDIS","USD")
	label variable `newvar_name' "`new_label'"
					
}

** convert input costs to USD
foreach var of varlist gfertilizer_total_cost_ha lfertilizer_total_cost_ha herbicide_total_cost_ha pesticide_total_cost_ha fungicide_total_cost_ha {
	local newvar_name = regexr("`var'","ha","usdha")
	gen `newvar_name' = `var'* `CEDI_USD'
	note `newvar_name': converted uinsg exchange rate of `CEDI_USD' USD per CEDI_USD
	order `newvar_name', after( `var')

	local original_label: variable label `var'
	local new_label = regexr("`original_label'","CEDIS","USD")
	label variable `newvar_name' "`new_label'"
					
}



local inputs = "gfertilizer lfertilizer herbicide pesticide fungicide"
local activities = "landclear 	landprep  planting 	gfertilizer 	lfertilizer 	manure_compost 	herbicide  pesticide 	fungicide 	weed 	pruning 	harvest 	podbreak 	ferment 	dry 	transport "
local types_of_work = "hired_n_ha hh_n_ha com_n_ha lab_n_ha hired_usdha"


foreach activity in `activities' {
	foreach type_of_work in `types_of_work'{
		*capture confirm variable `activity'_`type_of_work'
		*if _rc == 0 {
			local this_label: variable label `activity'_`type_of_work'
			gen li_`activity'_`type_of_work' = `activity'_`type_of_work'
			label variable li_`activity'_`type_of_work' "`this_label'"
		*}
	}
}

forvalues group = 1/3{
foreach activity in `activities' {
	foreach type_of_work in `types_of_work'{
		*capture confirm variable `activity'_`type_of_work'
		*if _rc == 0 {
			qui: sum `activity'_`type_of_work' if grouping == `group' & `activity'_yn == 1, det
			disp "Input values for `activity', group `group'"
			replace li_`activity'_`type_of_work' = `r(p50)' if grouping == `group' & li_`activity'_`type_of_work' == . & `activity'_yn == 1
		*}
	}
}
}

egen li_hired_usdha = rowtotal( ///
 li_landclear_hired_usdha li_landprep_hired_usdha li_planting_hired_usdha li_gfertilizer_hired_usdha li_lfertilizer_hired_usdha li_manure_compost_hired_usdha ///
 li_herbicide_hired_usdha li_pesticide_hired_usdha li_fungicide_hired_usdha li_weed_hired_usdha li_pruning_hired_usdha li_harvest_hired_usdha li_podbreak_hired_usdha ///
 li_ferment_hired_usdha li_dry_hired_usdha li_transport_hired_usdha), missing
 
label variable li_hired_usdha "Cocoa hired labour costs (USD/ha)"
remove_outliers li_hired_usdha


foreach input in `inputs' {
	*capture confirm variable `input'_usdha
	*if _rc == 0 {
		local this_label: variable label `input'_total_cost_usdha
		gen li_`input'_total_cost_usdha = `input'_total_cost_usdha
		label variable li_`input'_total_cost_usdha "`this_label'"
	*}
}

forvalues group = 1/3{
foreach input in `inputs' {
	*capture confirm variable `input'_usdha
	*if _rc == 0 {
		qui: sum `input'_total_cost_usdha if  grouping == `group' & `input'_yn == 1, det
		disp "input values for `input', group `group'"
		replace li_`input'_total_cost_usdha = `r(p50)' if  grouping == `group' & li_`input'_total_cost_usdha == . & `input'_yn == 1
	*}
}
}
egen li_inputs_usdha = rowtotal( li_gfertilizer_total_cost_usdha li_lfertilizer_total_cost_usdha li_herbicide_total_cost_usdha li_pesticide_total_cost_usdha li_fungicide_total_cost_usdha), missing
label variable li_inputs_usdha "Cocoa input costs (USD/ha)"
remove_outliers li_inputs_usdha


* price:
qui: sum price_common_bag 
gen price_usdkg = `r(mean)'/64*`CEDI_USD'
label variable price_usdkg "Cocoa price (USD/kg)"

* cocoa_revenue
gen revenue_usdha = prod_total_last_kg_ha*price_usdkg
label variable revenue_usdha "Value of production (usd/ha)"
order revenue_usdha, after(prod_total_last_kg_ha)
note revenue_usdha : Cocoa values computed over hectares of trees older than 5years old
	

gen revenue_total =revenue_usdha* cocoa_land_used_morethan5_ha
label variable revenue_total "Cocoa value of production (USD)"
order revenue_total, before(revenue_usdha)
remove_outliers revenue_total
note revenue_total : Remove Outliers (4sd) applied to values above 0 per country


** CPI Correction
* CPI from
* http://data.imf.org/regular.aspx?key=61545849
* Ghana CPI in 2018 Q1: 247.05
* Ghana CPI in 2019 Q1: 269.66
* LI CEDI_USD = 1/4.45 // March 1st
local CEDI_USD = 0.20359 // Jan 15th, 2019
local correction_factor = (1/0.20359)/269.66*247.05/4.45

foreach var in price_usdkg li_inputs_usdha li_hired_usdha revenue_usdha revenue_total {
	gen `var'_2018 = `var'*`correction_factor'
	local original_label: variable label  `var'
	label variable `var'_2018 "`original_label'"
	note `var': corrected for march/2018
}

* (yield  * price - input costs - hired labour cost) * productive land / income from cocoa
gen total_hh_income_2018 = (prod_total_last_kg_ha * price_usdkg_2018 - li_inputs_usdha_2018 - li_hired_usdha_2018)*cocoa_land_used_morethan5_ha/(income_cocoa_perc)
label variable total_hh_income_2018 "Estimated total household income (USD/household/year)"
replace total_hh_income_2018 = . if total_hh_income<0
remove_outliers total_hh_income_2018

gen total_income_2018 = (prod_total_last_kg_ha * price_usdkg_2018- li_inputs_usdha_2018 - li_hired_usdha_2018)*cocoa_land_used_morethan5_ha
label variable total_income_2018 "Estimated total cocoa income (USD/household/year)"
replace total_income_2018 = . if total_income<0
remove_outliers total_income_2018

gen li_inputs_usdhh_2018=li_inputs_usdha_2018*cocoa_land_used_morethan5_ha
gen li_hired_usdhh_2018=li_hired_usdha_2018*cocoa_land_used_morethan5_ha

label variable li_hired_usdhh_2018 "Cocoa hired labour costs (USD/hh)"
label variable li_inputs_usdhh_2018 "Cocoa input costs (USD/hh)"

gen li_costs_usdhh_2018 = li_inputs_usdhh_2018 + li_hired_usdhh_2018
label variable li_costs_usdhh_2018 "Cocoa farm costs (USD/hh)"

gen li_costs_usdha_2018 = li_inputs_usdha_2018 + li_hired_usdha_2018
label variable li_costs_usdha_2018 "Cocoa farm costs (USD/ha)"


* benchmark
gen li_benchmark_achieved = .
label variable li_benchmark_achieved "Achived Living Income Benchmark"
label define lblLI_ACHIEVE 0 "Not achieved" 1 "Achieved"
label values li_benchmark_achieved lblLI_ACHIEVE


replace li_benchmark_achieved = 1 if total_hh_income_2018 > 4742 & grouping == 1 & total_hh_income_2018!=.
replace li_benchmark_achieved = 1 if total_hh_income_2018 > 5123 & grouping == 2 & total_hh_income_2018!=.
replace li_benchmark_achieved = 1 if total_hh_income_2018 > 4001 & grouping == 3 & total_hh_income_2018!=.

replace li_benchmark_achieved = 0 if li_benchmark_achieved == . & total_hh_income !=. 

***********
foreach activity in `activities' {
		*capture confirm variable `activity'_hh_n_ha
		*if _rc == 0 {
			local this_label: variable label `activity'_hh_n_ha
			gen li_`activity'_hh_n_hh = `activity'_hh_n_ha*cocoa_land_used_morethan5_ha 
			label variable li_`activity'_hh_n_hh "`this_label', Person-days"
		*}
}

***************************************************
label variable cocoa_land_used_morethan5_ha "Productive cocoa land (ha)"
label variable prod_total_last_kg_ha "Cocoa productivity (kg/ha/household)"
label variable revenue_usdha_2018 "Value of cocoa production (USD/ha/household)"
label variable li_inputs_usdha_2018 "Cocoa input costs (USD/ha/household)"
label variable li_hired_usdha_2018 "Cocoa hired labor costs (USD/ha/household)"
label variable total_hh_income_2018 "Estimated total household income (USD/year/household)"
label variable total_income_2018 "Estimated net cocoa income (USD/year/household)"
 
compress
save data_cleaned_LI, replace

