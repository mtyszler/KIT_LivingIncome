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
INSTITUTE and COSA. Available at: https://bitbucket.org/kitimpactteam/living-income-calculations/

-----------------------------------------------------------------------------
Last Update:
13/01/2020

*****************************************************************************/

version 15.1 
capture program drop KITLI_farmlevelmodel
program define KITLI_farmlevelmodel, sortpreserve
	syntax varname(numeric) [if] [in], ///
	total_main_income(varname numeric) ///
	total_hh_income(varname numeric) ///
	total_production(varname numeric) ///
	productive_farm(varname numeric) ///
	price(varname numeric) ///
	revenue_total(varname numeric) ///
	input_costs(varname numeric) ///
	hiredlabour_cost(varname numeric) ///
	all_costs(varname numeric) ///
	hh_size(varname numeric) ///
	filename(string) ///
	wsheet(string) ///
	[grouping_var(varname numeric) ///
	label_currency(string) ///
	label_weight(string) ///
	label_land(string) ///
	statistic(string)] 

	
	** mark if and in
	marksample touse, novarlist

	** rename varlist:
	local li_benchmark = "`varlist'"

	** load defaults in case optional arguments are skipped:	
	capture confirm existence `label_currency'
	if _rc == 6 {
		local label_currency = "USD"
	}
	capture confirm existence `label_weight'
	if _rc == 6 {
		local label_weight = "kg"
	}
	capture confirm existence `label_land'
	if _rc == 6 {
		local label_land = "ha"
	}
	capture confirm existence `statistic'
	if _rc == 6 {
		local export_what = "mean"
		local export_what_text = "average"
	}
	else {
		local export_what = "`statistic'"
	}
	

	* translate:
	if "`export_what'" == "p50" {
		local export_what_text = "median"
	}
	else if "`export_what'" == "p1" {
		local export_what_text = "1st percentile"
	}
	else if "`export_what'" == "p5" {
		local export_what_text = "5th percentile"
	}
	else if "`export_what'" == "p10" {
		local export_what_text = "10th percentile"
	}
	else if "`export_what'" == "p25" {
		local export_what_text = "25th percentile"
	}
	else if "`export_what'" == "p75" {
		local export_what_text = "75th percentile"
	}
	else if "`export_what'" == "p90" {
		local export_what_text = "90th percentile"
	}
	else if "`export_what'" == "p95" {
		local export_what_text = "95th percentile"
	}
	else if "`export_what'" == "p99" {
		local export_what_text = "99th percentile"
	}

	** Prep excel file:
	capture putexcel close
	capture putexcel clear
	putexcel set "`filename'", sheet("`wsheet'") modify open

	if "`grouping_var'" !="" {
		
		qui: levelsof `grouping_var' if `touse', local(group_levels)
	 
	}


	**** Prepare row headers
		local this_col_str = "B"
		local this_row = 1

		** Title
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "`export_what_text' values",  font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

		* Productivity
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Yield (`label_weight'/`label_land')*"

		* Farm size
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Productive farm (`label_land'/household)"

		* Total Production 
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Total production (`label_weight'/ household)"
			
		* Price
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Price (`label_currency'/`label_weight')"

		* Value of prod
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Value of production (`label_currency'/household)"

		* input costs
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Input costs (`label_currency'/household)"

		* hired labour
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Hired labour costs (`label_currency'/household)"

		* total costs
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Total costs (`label_currency'/household)"

		* main income
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Net income main crop (`label_currency'/household)", bold 

		* Living income title
		local this_row = `this_row' + 1 
		qui: putexcel `this_col_str'`this_row'= "Average household income", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

		* Income share
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Main income share of total*"

		* Total income
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Total income (`label_currency'/household)", bold 

		* LI benchmark
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Living income benchmark"

		* LI GAP
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "Gap to the living income*"

		* household size
		local this_row = `this_row' + 2
		qui: putexcel `this_col_str'`this_row'=  "Household size", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

		* sample size title
		local this_row = `this_row' + 2
		qui: putexcel `this_col_str'`this_row'= "Sample size", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 

		* observation
		local this_row = `this_row' + 2
		qui: putexcel `this_col_str'`this_row'= "*Calculated in the worksheet based on `export_what_text' values", italic 

	**** Export content for all
		local this_col_str = "C"
		local this_row = 1
		local title = "All"

		** Title
		disp "Exporting `title'"
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= "`title'", font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") 
			
		* Productivity
		local this_row = `this_row' + 1
		local p1 = `this_row'+2
		local p2 = `this_row'+1
		qui: putexcel `this_col_str'`this_row'= formula(`this_col_str'`p1'/`this_col_str'`p2'), nformat(number_sep)  
			
		* Farm size
		qui: sum `productive_farm' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(0.0) 
			
		* Total Production 
		qui: sum `total_production' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_sep) 
				
		* Price
		qui: sum `price' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

		* Value of prod
		qui: sum `revenue_total' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra)  

		* input costs
		qui: sum `input_costs' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

		* hired labour
		qui: sum `hiredlabour_costs' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

		* total costs
		qui: sum `all_costs' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

		* main income
		qui: sum `total_main_income' if `touse', det
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
		qui: sum `total_hh_income' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

		* LI benchmark
		qui: sum `li_benchmark' if `touse', det
		local this_row = `this_row' + 1
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 

		* LI GAP
		local this_row = `this_row' + 1
		local p1 = `this_row'-2
		local p2 = `this_row'-1
		qui: putexcel `this_col_str'`this_row'= formula(1-`this_col_str'`p1'/`this_col_str'`p2'), nformat(percent) 
		

		* household size
		qui: sum `hh_size' if `touse', det
		local this_row = `this_row' + 2
		qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_d2 ) 

		* sample size 
		local this_row = `this_row' + 2
		qui: putexcel `this_col_str'`this_row'= `r(N)' ,  nformat(number) 


		
	if "`grouping_var'" !="" {	
		**** Export content for groups
		// D = ASCII(68)
		local this_col = 68

		foreach group in `group_levels' {
			local this_row = 1
			local this_col_str = char(`this_col')
			

			local title: label (`grouping_var') `group'

			** Title
			disp "Exporting `title'"
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= "`title'" , font(Calibri, 11, white) bold fpattern(solid,  "91 155 213") hcenter 
				
			* Productivity
			local this_row = `this_row' + 1
			local p1 = `this_row'+2
			local p2 = `this_row'+1
			qui: putexcel `this_col_str'`this_row'= formula(`this_col_str'`p1'/`this_col_str'`p2'), nformat(number_sep) 
				
			* Farm size
			qui: sum `productive_farm' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(0.0) 
				
			* Total Production 
			qui: sum `total_production' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_sep) 
					
			* Price
			qui: sum `price' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1 
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* Value of prod
			qui: sum `revenue_total' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* input costs
			qui: sum `input_costs' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* hired labour
			qui: sum `hiredlabour_costs' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* total costs
			qui: sum `all_costs' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* main income
			qui: sum `total_main_income' if  `grouping_var'==`group' & `touse', det
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
			qui: sum `total_hh_income' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* LI benchmark
			qui: sum `li_benchmark' if  `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 1 
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(currency_d2_negbra) 
			
			* LI GAP
			local this_row = `this_row' + 1
			local p1 = `this_row'-2
			local p2 = `this_row'-1
			qui: putexcel `this_col_str'`this_row'= formula(1-`this_col_str'`p1'/`this_col_str'`p2'), nformat(percent) 
			
			* household size
			qui: sum `hh_size' if   `grouping_var'==`group' & `touse', det
			local this_row = `this_row' + 2
			qui: putexcel `this_col_str'`this_row'= `r(`export_what')', nformat(number_d2 ) 
			
			* sample size 
			local this_row = `this_row' + 2
			qui: putexcel `this_col_str'`this_row'= `r(N)',  nformat(number) 
			
			***
			local this_col = `this_col' + 1

		}
		
	}

	putexcel close
	putexcel clear

end


