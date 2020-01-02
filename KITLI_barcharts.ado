/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces bar charts of the Gap to the Living Income Benchmark
It assumes that there are two main sources of income.

It produces graphs similar to what can be seen at:
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

version 15.1 
capture program drop KITLI_barcharts
program define KITLI_barcharts, sortpreserve
	syntax varname(numeric) [if] [in], ///
	total_main_income(varname numeric) ///
	total_hh_income (varname numeric) ///
	[grouping_var(varname numeric) ///
	label_currency(string) ///
	label_main_income(string) ///
	label_remaining_income(string) /// 
	color_main(string) ///
	color_remaining(string) ///
	color_gap(string) ///
	color_food(string) ///
	subfolder(string) ///
	median ///
	as_share /// 
	food(numlist >0 max = 1) ///
	nosave]
	
	
	** mark if and in
	marksample touse, novarlist


	** rename varlist:
	local li_benchmark = "`varlist'"
	
	** load defaults in case optional arguments are skipped:	
	capture confirm existence `label_currency'
	if _rc == 6 {
		local label_currency = "USD"
	}
	capture confirm existence `label_main_income'
	if _rc == 6 {
		local label_main_income = "Income from main crop"
	}
	capture confirm existence `label_remaining_income'
	if _rc == 6 {
		local label_remaining_income = "Other income"
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

	
	*** create tempvars & temp names
	tempvar temp_gap_main temp_gap_total temp_gap_benchmark temp_benchmark temp_food
  
	* create sub-folder if not existent:
	if "`subfolder'" != "" {
		if ustrright("`subfolder'", 1) != "\" {
			local subfolder = "`subfolder'" + "\"
		}
		capture mkdir "`subfolder'"
	}
	 	
	** Prepare values for the graphs
	if "`median'" == "median" {

		*** Prepare gap to the MEDIAN INCOME
		
		if "`grouping_var'" !="" {

			qui: by `grouping_var', sort: egen `temp_gap_main' = median(`total_main_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_gap_total' = median(`total_hh_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_benchmark' = median(`li_benchmark') if `touse'
			
			local this_over = ", over(`grouping_var')"
		}
		else {
			qui: egen `temp_gap_main' = median(`total_main_income') if `touse'
			qui: egen `temp_gap_total' = median(`total_hh_income') if `touse'
			qui: egen `temp_benchmark' = median(`li_benchmark') if `touse'
			
			local this_over = ", "
		}

		local this_title = "Median values"
		local this_filename = "`subfolder'bar_LI_gap_median"
	
	
	
	} 
	else {
	
		*** Prepare gap to the MEAN INCOME
		
		if "`grouping_var'" !="" {

			qui: by `grouping_var', sort: egen `temp_gap_main' = mean(`total_main_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_gap_total' = mean(`total_hh_income') if `touse'
			qui: by `grouping_var', sort: egen `temp_benchmark' = mean(`li_benchmark') if `touse'
			
			local this_over = ", over(`grouping_var')"
		}
		else {
			qui: egen `temp_gap_main' = mean(`total_main_income') if `touse'
			qui: egen `temp_gap_total' = mean(`total_hh_income') if `touse'
			qui: egen `temp_benchmark' = mean(`li_benchmark') if `touse'
			
			local this_over = ", "
		}

		
		local this_title = "Mean values"
		local this_filename = "`subfolder'bar_LI_gap_mean"
	}
	 
	qui: gen `temp_gap_benchmark' = `temp_benchmark' - `temp_gap_total' if `touse'
	qui: replace `temp_gap_total' = `temp_gap_total' - `temp_gap_main' if `touse'
	 
	local this_ytitle =  "`label_currency'/year/household"
	
	* Adjustments if share
	if "`as_share'" == "as_share" {
		qui: replace `temp_gap_benchmark' = `temp_gap_benchmark'/`temp_benchmark'*100 if `touse'
		qui: replace `temp_gap_total' = `temp_gap_total'/`temp_benchmark'*100 if `touse'
		qui: replace `temp_gap_main' = `temp_gap_main'/`temp_benchmark'*100 if `touse'
		
		local this_title = "`this_title'" + " in relation to the benchmark value"
		local this_filename = "`this_filename'" + "_as_share"
		local this_ytitle =  "% of the benchmark value"
	}
	
	 
	
	
	** Check for Food specification
	if "`food'" !="" {
		qui: gen `temp_food' = `food' if `touse'
		local this_filename = "`this_filename'" + "_with_food"
		
		if "`as_share'" == "as_share" {
			qui: replace `temp_food' =  `temp_food'/`temp_benchmark'*100 if `touse'
			qui: replace `temp_gap_benchmark' = `temp_gap_benchmark' - `temp_food' if `touse'
		}
		
		qui: replace `temp_gap_benchmark' =  `temp_gap_benchmark' - `temp_food' if `touse'

		graph bar (mean) `temp_gap_main' `temp_gap_total' `temp_food' `temp_gap_benchmark' if `to_use' `this_over' ///
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
	else {
	
		* Generate graph
		graph bar (mean) `temp_gap_main' `temp_gap_total'  `temp_gap_benchmark' if `to_use'  `this_over' ///
		stack legend(label(1 "`label_main_income'") label(2 "`label_remaining_income'") label(3 "Gap to the Living Income Benchmark")) ///
		ytitle("`this_ytitle'")  ///
		bar(1, color(`color_main')) ///
		bar(2, color(`color_remaining')) ///
		bar(3, color(`color_gap')) ///
		blabel(bar, format(%9.0f) position(center) ) ///
		graphregion(color(white)) bgcolor(white) ///
		title("`this_title'")
		 
	}
	
	* save graph
	if "`save'" != "nosave" {
		graph export "`this_filename'.png", width(1000) replace
	}
	


end
