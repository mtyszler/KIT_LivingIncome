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
17/04/2020

*****************************************************************************/

version 15.1 
capture program drop KITLI_gap2bm
program define KITLI_gap2bm, sortpreserve
	syntax varname(numeric) [if] [in], ///
	total_hh_income(varname numeric) ///
	[total_main_income(varname numeric) ///
	metric(string) ///
	grouping_var(varname numeric) ///
	label_currency(string) ///
	label_time(string) ///
	label_main_income(string) ///
	label_remaining_income(string) /// 
	color_main(string) ///
	color_remaining(string) ///
	color_gap(string) ///
	color_food(string) ///
	show_graph ///
	save_as(string) ///
	as_share /// 
	food(numlist >0 max = 1)]
	
	

	********************************************
	** Prepare observations which will be used 
	marksample touse, novarlist

	
	********************************************
	** check for valid combination of inputs:
	if "`label_main_income'" !="" & "`total_main_income'" == ""   {
		display as error "ERROR: {it:label_main_income} can only be used if {it:total_main_income} is also provided."
		error 184
		exit
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
	capture confirm existence `label_remaining_income'
	if _rc == 6 {
		if "`total_main_income'" =="" {
			local label_remaining_income = "Total income"
		} 
		else {
			local label_remaining_income = "Other income"
		}
	}
	capture confirm existence `label_main_income'
	if _rc == 6 {
		local label_main_income = "Income from main crop"
	}
	capture confirm existence `color_main'
	if _rc == 6 {
		local color_main = "blue%30"
	}
	capture confirm existence `color_remaining'
	if _rc == 6 {
		local color_remaining = "ebblue%30"
	}
	capture confirm existence `color_gap'
	if _rc == 6 {
		local color_gap = "red%80"
	}
	capture confirm existence `color_food'
	if _rc == 6 {
		local color_food = "orange%30"
	}


	********************************************
	** check for valid inputs
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




	********************************************
	*** create tempvars
	tempvar temp_gap_main temp_gap_total temp_gap_benchmark temp_benchmark temp_food
  

  	** rename key variable:
	local li_benchmark = "`varlist'"
 	
	** Prepare calculations
	if "`metric'" == "median" {

		*** Prepare gap to the MEDIAN INCOME
		local text_tbl = "Gap of the median income to the Living Income Benchmark"
		
		if "`grouping_var'" !="" {
			if "`total_main_income'" != "" {
				qui: by `grouping_var', sort: egen `temp_gap_main' = median(`total_main_income') if `touse'
			}
			qui: by `grouping_var', sort: egen `temp_gap_total' = median(`total_hh_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_benchmark' = median(`li_benchmark') if `touse'
			
			local this_over = ", over(`grouping_var')"
		}
		else {
			if "`total_main_income'" != "" {
				qui: egen `temp_gap_main' = median(`total_main_income') if `touse'
			}
			qui: egen `temp_gap_total' = median(`total_hh_income') if `touse'
			qui: egen `temp_benchmark' = median(`li_benchmark') if `touse'
			
			local this_over = ", "
		}

		local this_title = "Median values"
	
	
	} 
	else if "`metric'" == "mean" {{
	
		*** Prepare gap to the MEAN INCOME
		local text_tbl = "Gap of the average income to the Living Income Benchmark"
		
		if "`grouping_var'" !="" {

			if "`total_main_income'" != "" {
				qui: by `grouping_var', sort: egen `temp_gap_main' = mean(`total_main_income') if `touse'
			}
			qui: by `grouping_var', sort: egen `temp_gap_total' = mean(`total_hh_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_benchmark' = mean(`li_benchmark') if `touse'
			
			local this_over = ", over(`grouping_var')"
		}
		else {
			if "`total_main_income'" != "" {
				qui: egen `temp_gap_main' = mean(`total_main_income') if `touse'
			}
			qui: egen `temp_gap_total' = mean(`total_hh_income') if `touse'
			qui: egen `temp_benchmark' = mean(`li_benchmark') if `touse'
			
			local this_over = ", "
		}

		
		local this_title = "Mean values"
	}

	else if "`metric'" == "FGT" {
	
		*** Prepare FGT metric
		local text_tbl = "FGT gap to the Living Income Benchmark"

		if "`total_main_income'" != "" {
			qui: gen `temp_gap_main' = `total_main_income' if `touse'
		}
		qui: gen `temp_gap_total' = `total_hh_income' if `touse'
		qui: gen `temp_benchmark' = `li_benchmark' if `touse'
					
		if "`grouping_var'" !="" {
			
			local this_over = ", over(`grouping_var')"
		}
		else {

			local this_over = ", "
		}

		
		local this_title = "FGT index"
	}
	 
	qui: gen `temp_gap_benchmark' = `temp_benchmark' - `temp_gap_total' if `touse'
	if "`total_main_income'" != "" {
		qui: replace `temp_gap_total' = `temp_gap_total' - `temp_gap_main' if `touse'
	}
	 
	local this_ytitle =  "`label_currency'/`label_time'/household"
	
	* Adjustments if share
	if "`as_share'" == "as_share" {
		qui: replace `temp_gap_benchmark' = `temp_gap_benchmark'/`temp_benchmark'*100 if `touse'
		qui: replace `temp_gap_total' = `temp_gap_total'/`temp_benchmark'*100 if `touse'
		if "`total_main_income'" != "" {
			qui: replace `temp_gap_main' = `temp_gap_main'/`temp_benchmark'*100 if `touse'
		}
		
		local this_title = "`this_title'" + " in relation to the benchmark value"
		local this_ytitle =  "% of the benchmark value"
		local this_ylabel = " ylabel(0(10)100, grid)"
	}

	* Adjustments FGT:
	if "`metric'" == "FGT" {
		local this_ytitle =  "Index value"

		qui: replace `temp_gap_benchmark' = 0 if `touse' & `temp_gap_benchmark' <0 & `temp_gap_benchmark' !=.

		qui: replace `temp_gap_benchmark' = `temp_gap_benchmark'/`temp_benchmark'*100 if `touse'
		qui: drop `temp_gap_total' 
		if "`total_main_income'" != "" {
			qui: drop `temp_gap_main' 
		}
		local this_ylabel = " ylabel(0(10)100, grid)"
	}
	
	 
	
	
	** Check for Food specification
	if "`food'" !="" {
		qui: gen `temp_food' = `food' if `touse'
		
		if "`as_share'" == "as_share" {
			qui: replace `temp_food' =  `temp_food'/`temp_benchmark'*100 if `touse'
			qui: replace `temp_gap_benchmark' = `temp_gap_benchmark' - `temp_food' if `touse'
		}
		
		qui: replace `temp_gap_benchmark' =  `temp_gap_benchmark' - `temp_food' if `touse'

		if "`show_graph'" !="" {
			graph bar (mean) `temp_gap_main' `temp_gap_total' `temp_food' `temp_gap_benchmark' if `touse' `this_over' ///
			stack legend(label(1 "`label_main_income'") label(2 "`label_remaining_income'") label(3 "Value of crops consumed at home") label(4 "Gap to the Living Income Benchmark") size(vsmall)) ///
			ytitle("`this_ytitle'")  ///
			bar(1, color(`color_main')) ///
			bar(2, color(`color_remaining')) ///
			bar(4, color(`color_gap')) ///
			bar(3, color(`color_food')) ///
			blabel(bar, format(%9.0f) position(center) ) ///
			graphregion(color(white)) bgcolor(white) ///
			title("`this_title'")
		}


	}
	else {

		* display some results
		if "`as_share'" == "as_share" {
			local show_pct = "%"
		} 
		else {
			local show_pct = " "
		}

		display in b _newline
		display in b "`text_tbl'" 


		if "`grouping_var'" !="" {

			qui: levelsof `grouping_var' if `touse', local(group_levels)

			foreach group in `group_levels' {

				local group_label: label (`grouping_var') `group'
		
				qui: sum `temp_benchmark' if `grouping_var' == `group' & `touse' 
				display in b ""
				display in b "`group_label'" 
				display in b "n = `r(N)'"
				di as text "{hline 73}"
				
				if "`metric'" != "FGT" {
					if "`total_main_income'" != "" {
						qui: sum `temp_gap_main' if `grouping_var' == `group' & `touse' 
						display as text %35s "`label_main_income':" /*
										*/ as result /*
										*/ %9.0f `r(mean)' "`show_pct'"
					}
					qui: sum `temp_gap_total' if `grouping_var' == `group' & `touse' 
					display as text %35s "`label_remaining_income':" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "`show_pct'"
					qui: sum `temp_gap_benchmark' if `grouping_var' == `group' & `touse' 
					display as text %35s "Gap to the Living Income Benchmark:" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "`show_pct'"
				}
				else {
					qui: sum `temp_gap_benchmark' if `grouping_var' == `group' & `touse' 
					display as text %35s "FGT index:" /*
									*/ as result /*
									*/ %9.0f `r(mean)' "%"

				}
				di as text "{hline 73}"
				qui: sum `temp_benchmark' if `grouping_var' == `group' & `touse'
				display as text %35s "Living Income Benchmark" /*
								*/ as result /*
								*/ %9.0f `r(mean)' 
			
			}

			display in b ""
			display in b "All groups"

		}

		qui: sum `temp_benchmark' if `touse'
		display in b "n = `r(N)'"
		di as text "{hline 73}"
		
		if "`metric'" != "FGT" {
			if "`total_main_income'" != "" {
				qui: sum `temp_gap_main' if `touse' 
				display as text %35s "`label_main_income':" /*
								*/ as result /*
								*/ %9.0f `r(mean)' "`show_pct'"
			}
			qui: sum `temp_gap_total' if `touse' 
			display as text %35s "`label_remaining_income':" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "`show_pct'"
			qui: sum `temp_gap_benchmark' if `touse' 
			display as text %35s "Gap to the Living Income Benchmark:" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "`show_pct'"
		}
		else {
			qui: sum `temp_gap_benchmark' if `touse' 
			display as text %35s "FGT index:" /*
							*/ as result /*
							*/ %9.0f `r(mean)' "%"

		}
		di as text "{hline 73}"
		qui: sum `temp_benchmark' if `touse'
		display as text %35s "Living Income Benchmark" /*
						*/ as result /*
						*/ %9.0f `r(mean)' 
		

	
		* Generate graph
		if "`show_graph'" !="" {

			if "`metric'" == "FGT" {
				graph bar (mean)  `temp_gap_benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "FGT index")) ///
				ytitle("`this_ytitle'") `this_ylabel' ///
				bar(1, color(`color_gap')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")

			}  
			else if "`total_main_income'" != "" {  
				graph bar (mean) `temp_gap_main' `temp_gap_total'  `temp_gap_benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "`label_main_income'") label(2 "`label_remaining_income'") label(3 "Gap to the Living Income Benchmark")) ///
				ytitle("`this_ytitle'") `this_ylabel' ///
				bar(1, color(`color_main')) ///
				bar(2, color(`color_remaining')) ///
				bar(3, color(`color_gap')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")
			}
			else {
				graph bar (mean) `temp_gap_total'  `temp_gap_benchmark' if `touse'  `this_over' ///
				stack legend(label(1 "`label_remaining_income'") label(2 "Gap to the Living Income Benchmark")) ///
				ytitle("`this_ytitle'")  `this_ylabel' ///
				bar(1, color(`color_remaining')) ///
				bar(2, color(`color_gap')) ///
				blabel(bar, format(%9.0f) position(center) ) ///
				graphregion(color(white)) bgcolor(white) ///
				title("`this_title'")
			}
		}
		 
	}
	
	* save graph/*
	if "`save_as'"!="" {
		graph export "`save_as'.png", width(1000) replace
	}
	*/


	
	


end
