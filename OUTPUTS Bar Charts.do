/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces bar charts of the Gap to the Living Income Benchmark
It assumes that there are two main sources of income.

It produces graphs similar to what can be seen at:
https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf
https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf


It assumes variables have already been calculated. 
If note, please check do-files:

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

* Sub-folder where the graphs will be saved:
*==> Notice the trailing "/"
* If no subfolder is required, replace the local by an empty string, ""
local sf = "Bar_Charts/"
*local sf = "" // uncomment for no subfolder


* Variables for which plots need to be created
* The plots will use the variable labels, therefore make sure these are clear and complete

* This the income variables to which the comparison will apply
local total_main_income = "total_income_2018" // total income from main source, for example main crop sales
local total_hh_income = "total_hh_income_2018" // total household income

* Set labels for the graphs:
local currency = "USD"
local label_main_income = "Income from main crop"
local label_remaining_income = "Other income"

* Values of the benchmark, per group, with increasing integer numbers in the order they appear:
* At least 1 benchmark is needed, if no grouping takes place
local li_benchmark_1 = 4742
local li_benchmark_2 = 5123
local li_benchmark_3 = 4001

** Intrinsice value of food
local food = 450 // include intrinsice value of food to be reduced from the gap
*local food = "" // uncomment to skip the food graph

* Grouping variable, replace by an empty string for no groupings
* The plots will use the group labels, therefore make sure these are clear and complete
local grouping_var = "grouping"
*local grouping_var = "" // uncomment for no groups

** Color for the groups:
* we preset 4 colors, add more if needed, with increasing integer numbers:
* %30 refers to 30% transparency
local color_main = "blue%30" // main source of income
local color_remaining = "ebblue%30" // remaining income
local color_gap = "red%80" // gap_color
local color_food = "orange%30" // intrinsic value of food


***** END OF TO BE ADJUSTED BY THE USER ********

***** TO BE ADJUSTED ONLY  BY ADVANCED USERS ********/
** As a user you should not modify the rows below.
** Only do so, if you are confident on what you are doing. 
 
 
 
 * load file
 use `ds_filename', replace
 
 * create sub-folder if not existent:
 capture mkdir "`sf'"
 
 preserve
 
 * Identify groups:
 if "`grouping_var'" !="" {
	
	levelsof `grouping_var', local(group_levels)
	drop if `grouping_var' == .
	 
 }
 

*** Prepare graph of gap to the MEAN INCOME 
capture drop gap* benchmark
if "`grouping_var'" !="" {

	by `grouping_var', sort: egen temp_gap_cocoa = mean(`total_main_income')
	by `grouping_var', sort: egen temp_gap_total = mean(`total_hh_income')
	
	local this_over = ", over(`grouping_var')"
}
else {
	egen temp_gap_cocoa = mean(`total_main_income')
	egen temp_gap_total = mean(`total_hh_income')
	
	local this_over = ", "
}

gen temp_benchmark = .
if "`grouping_var'" !="" {
	local counter = 1
	foreach group in `group_levels' {
	
		replace  temp_benchmark = `li_benchmark_`counter'' if `grouping_var' == `group'
		local counter = `counter'+1
		
	}
} 
else {
	replace temp_benchmark = `li_benchmark_1'
}

gen temp_gap_benchmark = temp_benchmark - temp_gap_total
replace temp_gap_total = temp_gap_total - temp_gap_cocoa

local label_main_income = "Income from main crop"
local label_remaining_income = "Other income"


 
graph bar (mean) temp_gap_cocoa temp_gap_total  temp_gap_benchmark `this_over' ///
stack legend(label(1 "`label_main_income'") label(2 "`label_remaining_income'") label(3 "Gap to the Living Income Benchmark")) ///
ytitle("`currency'/year/household")  ///
bar(1, color(`color_main')) ///
bar(2, color(`color_remaining')) ///
bar(3, color(`color_gap')) ///
blabel(bar, format(%9.0f) position(center) ) ///
graphregion(color(white)) bgcolor(white) ///
title("Mean values")
 
graph export "`sf'`var'bar_LI_gap_mean.png", width(1000) replace
 
** MEAN, ncluding value of food 
if "`food'" !="" {
	gen temp_food = `food'
	replace temp_gap_benchmark =  temp_gap_benchmark - temp_food
	 
	graph bar (mean) temp_gap_cocoa temp_gap_total  temp_food temp_gap_benchmark `this_over' ///
	stack legend(label(1 "`label_main_income'") label(2 "`label_remaining_income'") label(3 "Value of crops consumed at home") label(4 "Gap to the Living Income Benchmark") size(vsmall)) ///
	ytitle("`currency'/year/household")  ///
	bar(1, color(`color_main')) ///
	bar(2, color(`color_remaining')) ///
	bar(4, color(`color_gap')) ///
	bar(3, color(`color_food')) ///
	blabel(bar, format(%9.0f) position(center) ) ///
	graphregion(color(white)) bgcolor(white) ///
	title("Mean values")
	 
	
	 
	graph export "`sf'`var'bar_LI_gap_FOOD_mean.png", width(1000) replace
}


*** Prepare graph of gap to the MEDIAN INCOME 
capture drop temp_gap* temp_benchmark
if "`grouping_var'" !="" {

	by `grouping_var', sort: egen temp_gap_cocoa = median(`total_main_income')
	by `grouping_var', sort: egen temp_gap_total = median(`total_hh_income')
	
	local this_over = ", over(`grouping_var')"
}
else {
	egen temp_gap_cocoa = median(`total_main_income')
	egen temp_gap_total = median(`total_hh_income')
	
	local this_over = ", "
}

gen temp_benchmark = .
if "`grouping_var'" !="" {
	local counter = 1
	foreach group in `group_levels' {
	
		replace  temp_benchmark = `li_benchmark_`counter'' if `grouping_var' == `group'
		local counter = `counter'+1
		
	}
} 
else {
	replace temp_benchmark = `li_benchmark_1'
}

gen temp_gap_benchmark = temp_benchmark - temp_gap_total
replace temp_gap_total = temp_gap_total - temp_gap_cocoa

local label_main_income = "Income from main crop"
local label_remaining_income = "Other income"


 
graph bar (mean) temp_gap_cocoa temp_gap_total  temp_gap_benchmark `this_over' ///
stack legend(label(1 "`label_main_income'") label(2 "`label_remaining_income'") label(3 "Gap to the Living Income Benchmark")) ///
ytitle("`currency'/year/household")  ///
bar(1, color(`color_main')) ///
bar(2, color(`color_remaining')) ///
bar(3, color(`color_gap')) ///
blabel(bar, format(%9.0f) position(center) ) ///
graphregion(color(white)) bgcolor(white) ///
title("Median values")
 
graph export "`sf'`var'bar_LI_gap_median.png", width(1000) replace
 

restore
