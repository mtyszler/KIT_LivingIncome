/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces an excel output with a farm level profit model for a single main crop.

It produces tables similar to what can be seen at:
https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf
https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf

It assumes variables have already been calculated. 
If not, please check do-files:

---------------------------------------------------------------------------

This opensource file was created and is maintained by Marcelo Tyszler
(m.tyszler@kit.nl), from KIT Royal Tropical Institute, Amsterdam.

This project was jointly done with COSA, and it was supported by
ISEAL, Living Income Community of Practice and GIZ

You are free to use it and modify for your needs. BUT PLEASE CITE US:

Tyszler, et al. (2019). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: 

-----------------------------------------------------------------------------
Last Update:
4/11/2019

*****************************************************************************/

***** TO BE ADJUSTED BY THE USER ********/
** As a user you need to adjust these values:


* Dataset:
local ds_filename = "data_cleaned_LI.dta"

* Excel template:
* This needs to be the name of an excel file which will be created by the do-file
* make sure it is a valid name and that, if exists, the file is closed.
local filename = "Farm Level model.xlsx"
* Valid name of worksheet within the excel file
local sheet = "Compare avg farms"


* Variables for which plots need to be created
* The plots will use the variable labels, therefore make sure these are clear and complete

* Components of the model per HOUSEHOLD.
* Please ensure that all land, weight and currency units are harmonized.
local total_main_income = "total_income_2018" // total income from main source, for example main crop sales
local total_hh_income = "total_hh_income_2018" // total household income
local total_production = "prod_total_last_kg" // total household production in one year
local productive_farm = "cocoa_land_used_morethan5_ha" // total area of household productive farm
local price = "price_usdkg_2018" // price per unit of weight of the production 
local revenue_total = "revenue_total_2018" // value of production
local input_costs= "li_inputs_usdhh_2018" // input costs per household per year
local hiredlabour_costs= "li_hired_usdhh_2018" // hired labour costs per household per year
local all_costs= "li_costs_usdhh_2018" // all costs per household per year	
local hh_size= "hhmem_number" // household size

local unit_land = "ha" // unit for land
local unit_currency = "USD" // unit for currency
local unit_weight = "kg" // unit for weight

* Values of the benchmark
local li_benchmark = "li_benchmark" // value of the li benchmark for each observation

* Grouping variable, replace by an empty string for no groupings
* The tables will use the group labels, therefore make sure these are clear and complete
* The code use the artificial code '-555' to capture all groups. So please make sure there is no group -555
local grouping_var = "grouping"
*local grouping_var = "" // uncomment for no groups

***** END OF TO BE ADJUSTED BY THE USER ********

***** TO BE ADJUSTED ONLY BY ADVANCED USERS ********/
** As a user you should not modify the rows below.
** Only do so, if you are confident on what you are doing. 

 
 * load file
 use `ds_filename', replace
 
****************************
* TEMP this needs to be removed later
gen benchmark_cluster = .
replace benchmark_cluster = 4742 if grouping == 1
replace benchmark_cluster = 5123 if grouping == 2
replace benchmark_cluster = 4001 if grouping == 3

by society_grp2, sort: egen li_benchmark = mean(benchmark_cluster)
* END OF Temp
*****************************************

 
** Prep excel file:
capture putexcel close
capture putexcel clear
putexcel set "`filename'", sheet("`sheet'") modify open
local export_what = "mean"

if "`grouping_var'" !="" {
	
	levelsof `grouping_var', local(group_levels)
	preserve
	drop if `grouping_var' == .
	 
}


**** Prepare row headers
	local this_col_str = "B"
	local this_row = 1

	** Title
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Average values",  font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

	* Productivity
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Yield (`unit_weight'/`unit_land')"

	* Farm size
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Productive farm (`unit_weight'/household)"

	* Total Production 
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Total production (`unit_weight'/ household)"
		
	* Price
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Price (`unit_currency'/`unit_weight')"

	* Value of prod
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Value of production (`unit_currency'/household)"

	* input costs
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Input costs (`unit_currency'/household)"

	* hired labour
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Hired labour costs (`unit_currency'/household)"

	* total costs
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Total costs (`unit_currency'/household)"

	* main income
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Net income main crop (`unit_currency'/household)", bold 

	* Living income title
	local this_row = `this_row' + 1 
	qui: putexcel `this_col_str'`this_row'= "Average household income", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

	* Income share
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Main income share of total"

	* Total income
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Total income (`unit_currency'/household)", bold 

	* LI benchmark
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Living income benchmark"

	* LI GAP
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "Gap to the living income"

	* household size
	local this_row = `this_row' + 2
	qui: putexcel `this_col_str'`this_row'=  "Household size", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

	* sample size title
	local this_row = `this_row' + 2
	qui: putexcel `this_col_str'`this_row'= "Sample size", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

	* sample size 
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "N"


**** Export content for all
	local this_col_str = "C"
	local this_row = 1
	local title = "All"

	** Title
	disp "`title'"
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "`title'", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 
		
	* Productivity
	local this_row = `this_row' + 1
	local p1 = `this_row'+2
	local p2 = `this_row'+1
	qui: putexcel `this_col_str'`this_row'= formula(`this_col_str'`p1'/`this_col_str'`p2'), nformat(number_sep)  
		
	* Farm size
	qui: sum `productive_farm' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(0.0) 
		
	* Total Production 
	qui: sum `total_production' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_sep) 
			
	* Price
	qui: sum `price' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

	* Value of prod
	qui: sum `revenue_total' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra)  

	* input costs
	qui: sum `input_costs' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

	* hired labour
	qui: sum `hiredlabour_costs' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

	* total costs
	qui: sum `all_costs' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

	* main income
	qui: sum `total_main_income'  , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* Living income title
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row',  overwritefmt font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

	* Income share
	local this_row = `this_row' + 1
	local p1 = `this_row'-2
	local p2 = `this_row'+1
	qui: putexcel `this_col_str'`this_row'= formula(`this_col_str'`p1'/`this_col_str'`p2'), nformat(percent) 

	* total income
	qui: sum `total_hh_income' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

	* LI benchmark
	qui: sum `li_benchmark' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

	* LI GAP
	local this_row = `this_row' + 1
	local p1 = `this_row'-2
	local p2 = `this_row'-1
	qui: putexcel `this_col_str'`this_row'= formula(1-`this_col_str'`p1'/`this_col_str'`p2'), nformat(percent) 
	

	* household size
	qui: sum `hh_size' , det
	local this_row = `this_row' + 2
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_d2 ) 

	* sample size 
	local this_row = `this_row' + 2
	qui: putexcel `this_col_str'`this_row'= `r(N)' ,  nformat(number) 

**** Export content for groups
// D = ASCII(68)
local this_col = 68

foreach group in `group_levels' {
	local this_row = 1
	local this_col_str = char(`this_col')
	

	local title: label (`grouping_var') `group'

	** Title
	disp "`title'"
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= "`title'" , font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") hcenter 
		
	* Productivity
	local this_row = `this_row' + 1
	local p1 = `this_row'+2
	local p2 = `this_row'+1
	qui: putexcel `this_col_str'`this_row'= formula(`this_col_str'`p1'/`this_col_str'`p2'), nformat(number_sep) 
		
	* Farm size
	qui: sum `productive_farm' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(0.0) 
		
	* Total Production 
	qui: sum `total_production' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_sep) 
			
	* Price
	qui: sum `price' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1 
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* Value of prod
	qui: sum `revenue_total' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* input costs
	qui: sum `input_costs' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* hired labour
	qui: sum `hiredlabour_costs' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* total costs
	qui: sum `all_costs' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* main income
	qui: sum `total_main_income' if  `grouping_var'==`group' , det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* Living income title
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row',  overwritefmt font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 
	
	* Income share
	local this_row = `this_row' + 1
	local p1 = `this_row'-2
	local p2 = `this_row'+1
	qui: putexcel `this_col_str'`this_row'= formula(`this_col_str'`p1'/`this_col_str'`p2'), nformat(percent) 
	
	* total income
	qui: sum `total_hh_income' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* LI benchmark
	qui: sum `li_benchmark' if  `grouping_var'==`group', det
	local this_row = `this_row' + 1 
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
	
	* LI GAP
	local this_row = `this_row' + 1
	local p1 = `this_row'-2
	local p2 = `this_row'-1
	qui: putexcel `this_col_str'`this_row'= formula(1-`this_col_str'`p1'/`this_col_str'`p2'), nformat(percent) 
	
	* household size
	qui: sum `hh_size' if   `grouping_var'==`group', det
	local this_row = `this_row' + 2
	qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_d2 ) 
	
	* sample size 
	local this_row = `this_row' + 2
	qui: putexcel `this_col_str'`this_row'= `r(N)',  nformat(number) 
	
	***
	local this_col = `this_col' + 1

}

putexcel close
putexcel clear

restore


