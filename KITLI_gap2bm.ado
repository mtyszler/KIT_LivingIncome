/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata ado-file produces tables and bar charts of the Gap to the Living Income Benchmark

It produces graphs similar to what can be seen at:
https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf
https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf

It assumes that key variables have already been calculated. Type
help KITLI_gap2bm for more details

---------------------------------------------------------------------------

This opensource file was created and is maintained by Marcelo Tyszler
(m.tyszler@kit.nl), from KIT Royal Tropical Institute, Amsterdam.

This project was jointly done with COSA, and it was supported by
ISEAL, Living Income Community of Practice and GIZ

You are free to use it and modify for your needs. BUT PLEASE CITE US:

Tyszler, et al. (2019). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: https://bitbucket.org/kitimpactteam/living-income-calculations/

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.

-----------------------------------------------------------------------------
Last Update:
01/05/2020

*****************************************************************************/

version 15.1 
capture program drop KITLI_gap2bm
program define KITLI_gap2bm, sortpreserve
	syntax varname(numeric) [if] [in], ///
	hh_income(varname numeric) ///
	[main_income(varname numeric) ///
	food_value(varname numeric) ///
	metric(string) ///
	grouping_var(varname numeric) ///
	label_currency(string) ///
	label_time(string) ///
	label_hh_income(string) /// 
	label_main_income(string) ///
	label_other_than_main_income(string) /// 
	label_food_value(string) /// 
	color_hh_income(string) ///
	color_main_income(string) ///
	color_other_than_main_income(string) ///
	color_food_value(string) ///
	color_gap(string) ///
	show_graph ///
	save_graph_as(string) ///
	as_share ///
	]
	
	

	********************************************
	** Prepare observations which will be used 
	marksample touse, novarlist


	********************************************
	** check for valid combination of inputs:

	* food value matching  matching elements
	if "`label_food_value'" !="" & "`food_value'" == ""   {
		display as error "WARNING: {it:label_food_value} will be ignored if {it:food_value} is not provided."
	}
	if "`color_food_value'" !="" & "`food_value'" == ""   {
		display as error "WARNING: {it:color_food_value} will be ignored if {it:food_value} is not provided."
	}


	** User needs to provide either hh_income only, or hh_income + main_income
	** if hh_income only is provided, only label_hh_income and color_hh_income are used
	** if hh_income + main_income is provided, only label_main_income + label_other_than_main_income and color_main_income + color_other_than_main_income are used

	* hh_income only is provided:
	if "`label_main_income'" !="" & "`main_income'" == ""   {
		display as error "WARNING: {it:label_main_income} will be ignored if {it:main_income} is not provided."
	}
	if "`label_other_than_main_income'" !="" & "`main_income'" == ""   {
		display as error "WARNING: {it:label_other_than_main_income} will be ignored if {it:main_income} is not provided."
	}
	if "`color_main_income'" !="" & "`main_income'" == ""   {
		display as error "WARNING: {it:color_main_income} will be ignored if {it:main_income} is not provided."
	}
	if "`color_other_than_main_income'" !="" & "`main_income'" == ""   {
		display as error "WARNING: {it:color_other_than_main_income} will be ignored if {it:main_income} is not provided."
	}
	

	* hh_income + main_income is provided:
	if "`label_hh_income'" !="" & "`main_income'" != ""   {
		display as error "WARNING: {it:label_hh_income} will be ignored if {it:main_income} is provided. Please use {it:label_main_income} and {it:label_other_than_main_income}"
	}
	if "`color_hh_income'" !="" & "`main_income'" != ""   {
		display as error "WARNING: {it:color_hh_income} will be ignored if {it:main_income} is provided. Please use {it:color_main_income} and {it:color_other_than_main_income}"
	}



	** color can only be provided if graph is requested:
	if "`show_graph'" == ""  & ("`color_hh_income'" !="" | "`color_main_income'" !="" | "`color_other_than_main_income'" !="" | "`color_food_value'" !="" | "`color_gap'" !="") {
		display as error "WARNING: Graph colors will be ignored if {it:show_graph} is not requested."
	}
	

	* Save graph can only be used if graph is requested
	if "`save_graph_as'" !="" & "`show_graph'" == ""   {
		display as error "WARNING: {it:save_graph_as} will be ignored if {it:show_graph} is not requested."
	}


	********************************************
	** load defaults in case optional arguments are skipped:	
	capture confirm existence `metric'
	if _rc == 6 {
		local metric = "mean"
	}
	capture confirm existence `label_currency'
	if _rc == 6 {
		local label_currency = "USD"
	}
	capture confirm existence `label_time'
	if _rc == 6 {
		local label_time = "year"
	}
	capture confirm existence `label_other_than_main_income'
	if _rc == 6 {
		local label_other_than_main_income = "Other income"
	}
	capture confirm existence `label_hh_income'
	if _rc == 6 {
		local label_hh_income = "Total income"
	}
	capture confirm existence `label_main_income'
	if _rc == 6 {
		local label_main_income = "Income from main crop"
	}
	capture confirm existence `label_food_value'
	if _rc == 6 {
		local label_food_value = "Value of crops consumed at home"
	}
	capture confirm existence `color_hh_income'
	if _rc == 6 {
		local color_hh_income = "blue%30"
	}
	capture confirm existence `color_main_income'
	if _rc == 6 {
		local color_main_income = "blue%30"
	}
	capture confirm existence `color_other_than_main_income'
	if _rc == 6 {
		local color_other_than_main_income = "ebblue%30"
	}
	capture confirm existence `color_gap'
	if _rc == 6 {
		local color_gap = "red%80"
	}
	capture confirm existence `color_food_value'
	if _rc == 6 {
		local color_food_value = "orange%30"
	}


	********************************************
	** check for valid metrics and as_share combination
	if "`metric'" != "mean" & "`metric'" != "median" & "`metric'" != "FGT"  {
		display as error "ERROR: metric can only be one of  {it:mean, median, FGT}"
		error 198
		exit
	}


	** check for valid combination of inputs
	if "`metric'" == "FGT" & "`as_share'" == "as_share"   {
		display as error "ERROR: {it:FGT} cannot be combined with {it:as_share} "
		error 184
		exit
	}

	** check for valid combination of inputs
	if "`metric'" == "FGT" & "`main_income'" != ""   {
		display as error "WARNING: {it:main_income} will be combined if metric is {it:FGT}"
	}


	********************************************
	** compose base ytitle for graphs and tables
	local this_ytitle =  "`label_currency'/`label_time'/household"
	local benchmark_unit =  "`this_ytitle'"

	********************************************
	*** create tempvars
	* key components
	tempvar temp_totalincome temp_mainincome temp_foodvalue temp_benchmark
	
	* gap components
	tempvar temp_gap2benchmark 
	tempvar temp_other_than_main 

  	** rename key variable:
	local li_benchmark = "`varlist'" 	

 	********************************************
	** Prepare calculations: median, mean or FGT

	if "`metric'" == "median" {

		*** Prepare gap to the MEDIAN INCOME

		if "`grouping_var'" !="" {
			if "`main_income'" != "" {
				qui: by `grouping_var', sort: egen `temp_mainincome' = median(`main_income') if `touse'
			}
			if "`food_value'" !="" {
				qui: by `grouping_var', sort: egen `temp_foodvalue' = median(`food_value') if `touse'
			}		
			qui: by `grouping_var', sort: egen `temp_totalincome' = median(`hh_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_benchmark' = median(`li_benchmark') if `touse'
			
			local this_over = ", over(`grouping_var')"
		}
		else {
			if "`main_income'" != "" {
				qui: egen `temp_mainincome' = median(`main_income') if `touse'
			}
			if "`food_value'" !="" {
				qui: egen `temp_foodvalue' = median(`food_value') if `touse'
			}
			qui: egen `temp_totalincome' = median(`hh_income') if `touse'
			qui: egen `temp_benchmark' = median(`li_benchmark') if `touse'
			
			local this_over = ", "
		}

		* Elements for the tables:
		local text_tbl = "Gap of the median income to the Living Income Benchmark"

		* Elements for the graphs
		local this_title = "Median values"
		
	} 

	else if "`metric'" == "mean" {
	
		*** Prepare gap to the MEAN INCOME

		if "`grouping_var'" !="" {

			if "`main_income'" != "" {
				qui: by `grouping_var', sort: egen `temp_mainincome' = mean(`main_income') if `touse' 
			}
			if "`food_value'" !="" {
				qui: by `grouping_var', sort: egen `temp_foodvalue' = mean(`food_value') if `touse' 
			}
			qui: by `grouping_var', sort: egen `temp_totalincome' = mean(`hh_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_benchmark' = mean(`li_benchmark') if `touse' 
			
			local this_over = ", over(`grouping_var')"
		}
		else {
			if "`main_income'" != "" {
				qui: egen `temp_mainincome' = mean(`main_income') if `touse' 
			}
			if "`food_value'" !="" {
				qui: egen `temp_foodvalue' = mean(`food_value') if `touse' 
			}
			qui: egen `temp_totalincome' = mean(`hh_income') if `touse' 
			qui: egen `temp_benchmark' = mean(`li_benchmark') if `touse' 
			
			local this_over = ", "
		}

		* Elements for the tables:
		local text_tbl = "Gap of the average income to the Living Income Benchmark"

		* Elements for the graphs
		local this_title = "Mean values"
	}

	else if "`metric'" == "FGT" {
	
		*** Prepare FGT metric (no means nor median)
		
		if "`food_value'" != "" {
			qui: gen `temp_foodvalue' = `food_value' if `touse'
		}
		qui: gen `temp_totalincome' = `hh_income' if `touse'
		qui: gen `temp_benchmark' = `li_benchmark' if `touse'
					
		if "`grouping_var'" !="" {
			
			local this_over = ", over(`grouping_var')"
		}
		else {

			local this_over = ", "
		}

		* Elements for the tables:
		local text_tbl = "FGT gap to the Living Income Benchmark"

		* Elements for the graphs
		local this_title = "FGT index"
	}
	 

	********************************************
	** Compute gap and other elements
	qui: gen `temp_gap2benchmark' = `temp_benchmark' - `temp_totalincome' if `touse'
	
	if "`main_income'" != "" {
		qui: gen `temp_other_than_main' = `temp_totalincome' - `temp_mainincome' if `touse'
	}
	if "`food_value'" != "" {
		qui: replace `temp_gap2benchmark' = `temp_gap2benchmark' - `temp_foodvalue' if `touse'
	} 
	
	* Elements for the tables:
	local show_pct = " "

	** Adjustments if share
	if "`as_share'" == "as_share" {
		qui: replace `temp_gap2benchmark' = `temp_gap2benchmark'/`temp_benchmark'*100 if `touse'
		if "`main_income'" != "" {
			qui: replace `temp_mainincome' = `temp_mainincome'/`temp_benchmark'*100 if `touse'
			qui: replace `temp_other_than_main' = `temp_other_than_main'/`temp_benchmark'*100 if `touse'
		} 
		else {
			qui: replace `temp_totalincome' = `temp_totalincome'/`temp_benchmark'*100 if `touse'
		}

		if "`food_value'" != "" {
			qui: replace `temp_foodvalue' =  `temp_foodvalue'/`temp_benchmark'*100 if `touse'
		}

		* Elements for the tables:
		local show_pct = "%"

		* Elements for the graphs
		local this_title = "`this_title'" + " in relation to the benchmark value"
		local this_ytitle =  "% of the benchmark value"
		local this_ylabel = " ylabel(0(10)100, grid)"
	}

	* Adjustments for FGT:
	if "`metric'" == "FGT" {
		qui: replace `temp_gap2benchmark' = 0 if `touse' & `temp_gap2benchmark' <0 & `temp_gap2benchmark' !=.
		qui: replace `temp_gap2benchmark' = `temp_gap2benchmark'/`temp_benchmark'*100 if `touse'

		* Elements for the graphs
		local this_ytitle =  "Index value"
		local this_ylabel = " ylabel(0(10)100, grid)"
	}
	
	 	
	********************************************
	* display table with results

	display in b _newline
	display in b "`text_tbl'" 

	if "`grouping_var'" !="" { // show per group, than total

		qui: levelsof `grouping_var' if `touse', local(group_levels)

		** per groups
		foreach group in `group_levels' {

			local group_label: label (`grouping_var') `group'
	
			qui: sum `temp_gap2benchmark' if `grouping_var' == `group' & `touse' 
			display in b ""
			display in b "`group_label'" 
			display in b "n = `r(N)'"
			display in b ""
			display as text %35s "" as text "`this_ytitle'"
			di as text "{hline 73}"
			
			if "`metric'" != "FGT" { // mean of median
				if "`main_income'" != "" {
					qui: sum `temp_mainincome' if `grouping_var' == `group' & `touse' 
					display as text %35s "`label_main_income':" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "`show_pct'"

					qui: sum `temp_other_than_main' if `grouping_var' == `group' & `touse' 
					display as text %35s "`label_other_than_main_income':" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "`show_pct'"
				}
				else {
					qui: sum `temp_totalincome' if `grouping_var' == `group' & `touse' 
					display as text %35s "`label_hh_income':" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "`show_pct'"
				}

				if "`food_value'" != "" {
					qui: sum `temp_foodvalue' if `grouping_var' == `group' & `touse' 
					display as text %35s "`label_food_value':" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "`show_pct'"
				}


				qui: sum `temp_gap2benchmark' if `grouping_var' == `group' & `touse' 
				display as text %35s "Gap to the Living Income Benchmark:" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}
			else { //FGT
				qui: sum `temp_gap2benchmark' if `grouping_var' == `group' & `touse' 
				display as text %35s "FGT index:" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "%"

			}

			di as text "{hline 73}"
			if "`as_share'" == "as_share" | "`metric'" == "FGT" {
				display as text %35s "" as text "`benchmark_unit'"
			}
			qui: sum `temp_benchmark' if `grouping_var' == `group' & `touse'
			display as text %35s "Living Income Benchmark" /*
							*/ as result /*
							*/ %9.0f `r(mean)' 
		
		}

		** all groups together
		qui: sum `temp_gap2benchmark' if `grouping_var' != . & `touse' 
		display in b ""
		display in b "All groups"
		display in b "n = `r(N)'"
		display in b ""
		display as text %35s "" as text "`this_ytitle'"
		di as text "{hline 73}"
	
		
		if "`metric'" != "FGT" { // mean of median
			if "`main_income'" != "" {
				qui: sum `temp_mainincome' if `grouping_var' != . & `touse' 
				display as text %35s "`label_main_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"

				qui: sum `temp_other_than_main' if `grouping_var' != . & `touse' 
				display as text %35s "`label_other_than_main_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}
			else {
				qui: sum `temp_totalincome' if `grouping_var' != . & `touse' 
				display as text %35s "`label_hh_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}

			if "`food_value'" != "" {
				qui: sum `temp_foodvalue' if `grouping_var' != . & `touse' 
				display as text %35s "`label_food_value':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}


			qui: sum `temp_gap2benchmark' if `grouping_var' != . & `touse' 
			display as text %35s "Gap to the Living Income Benchmark:" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "`show_pct'"
		}
		else { //FGT
			qui: sum `temp_gap2benchmark' if `grouping_var' != . & `touse' 
			display as text %35s "FGT index:" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "%"

		}

		di as text "{hline 73}"
		if "`as_share'" == "as_share" | "`metric'" == "FGT"  {
			display as text %35s "" as text "`benchmark_unit'"
		}
		qui: sum `temp_benchmark' if `grouping_var' != . & `touse'
		display as text %35s "Living Income Benchmark" /*
						*/ as result /*
						*/ %9.0f `r(mean)' 

	}
	else { // no groups

		qui: sum `temp_gap2benchmark' if  `touse' 
		display in b ""
		display in b "n = `r(N)'"
		display in b ""
		display as text %35s "" as text "`this_ytitle'"
		di as text "{hline 73}"
		
		if "`metric'" != "FGT" { // mean of median
			if "`main_income'" != "" {
				qui: sum `temp_mainincome' if  `touse' 
				display as text %35s "`label_main_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"

				qui: sum `temp_other_than_main' if `touse' 
				display as text %35s "`label_other_than_main_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}
			else {
				qui: sum `temp_totalincome' if  `touse' 
				display as text %35s "`label_hh_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}

			if "`food_value'" != "" {
				qui: sum `temp_foodvalue' if  `touse' 
				display as text %35s "`label_food_value':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}


			qui: sum `temp_gap2benchmark' if `touse' 
			display as text %35s "Gap to the Living Income Benchmark:" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "`show_pct'"
		}
		else { //FGT
			qui: sum `temp_gap2benchmark' if `touse' 
			display as text %35s "FGT index:" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "%"

		}

		di as text "{hline 73}"
		if "`as_share'" == "as_share" | "`metric'" == "FGT"  {
			display as text %35s "" as text "`benchmark_unit'"
		}
		qui: sum `temp_benchmark' if  `touse'
		display as text %35s "Living Income Benchmark" /*
						*/ as result /*
						*/ %9.0f `r(mean)' 
	}

	********************************************
	* Generate graphs
	if "`show_graph'" !="" {

		if "`metric'" == "FGT" {
			graph bar (mean)  `temp_gap2benchmark' if `touse'  `this_over' ///
			stack legend(label(1 "FGT index")) ///
			ytitle("`this_ytitle'") `this_ylabel' ///
			bar(1, color(`color_gap')) ///
			blabel(bar, format(%9.0f) position(center) ) ///
			graphregion(color(white)) bgcolor(white) ///
			title("`this_title'")

		}  
		else if "`main_income'" != "" {  
			if "`food_value'" == "" { // no food
				graph bar (mean) `temp_mainincome' `temp_other_than_main'  `temp_gap2benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "`label_main_income'") label(2 "`label_other_than_main_income'") label(3 "Gap to the Living Income Benchmark")) ///
				ytitle("`this_ytitle'") `this_ylabel' ///
				bar(1, color(`color_main_income')) ///
				bar(2, color(`color_other_than_main_income')) ///
				bar(3, color(`color_gap')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")
			}
			else { // with food
				graph bar (mean) `temp_mainincome' `temp_other_than_main' `temp_foodvalue' `temp_gap2benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "`label_main_income'") label(2 "`label_other_than_main_income'") label(3 "`label_food_value'") label(4 "Gap to the Living Income Benchmark") size(vsmall)) ///
				ytitle("`this_ytitle'") `this_ylabel' ///
				bar(1, color(`color_main_income')) ///
				bar(2, color(`color_other_than_main_income')) ///
				bar(4, color(`color_gap')) ///
				bar(3, color(`color_food_value')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")
			}
		}
		else {
			if "`food_value'" == "" { // no food
				graph bar (mean) `temp_totalincome'  `temp_gap2benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "`label_hh_income'") label(2 "Gap to the Living Income Benchmark")) ///
				ytitle("`this_ytitle'")  `this_ylabel' ///
				bar(1, color(`color_hh_income')) ///
				bar(2, color(`color_gap')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")
			}
			else { // with food
				graph bar (mean) `temp_totalincome' `temp_foodvalue' `temp_gap2benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "`label_hh_income'")  label(2 "`label_food_value'") label(3 "Gap to the Living Income Benchmark") size(vsmall)) ///
				ytitle("`this_ytitle'") `this_ylabel' ///
				bar(1, color(`color_hh_income')) ///
				bar(2, color(`color_gap')) ///
				bar(3, color(`color_food_value')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")
			}
		}
	}
		 
	
	* save graph *
	if "`save_graph_as'" != "" {
		graph export "`save_graph_as'.png", as(png) width(1000) replace 
	}



end
