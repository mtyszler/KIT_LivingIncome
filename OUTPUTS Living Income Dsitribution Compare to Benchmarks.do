/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces density (kernel smoothened) plots as fractions about 
the total household income with the goal of comparing to the benchmark value

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
1/11/2019

*****************************************************************************/


***** TO BE ADJUSTED BY THE USER ********/
** As a user you need to adjust these values:


* Dataset:
local ds_filename = "data_cleaned_LI.dta"

* Sub-folder where the graphs will be saved:
*==> Notice the trailing "/"
* If no subfolder is required, replace the local by an empty string, ""
local sf = "Density_plots_fraction/"
*local sf = "" // uncomment for no subfolder

* Variables for which plots need to be created
* The plot will use the variable label, therefore make sure these are clear and complete

* This list is for variables to which the smoothening plot applies
local total_hh_income = "total_hh_income"

* Grouping variable, replace by an empty string for no groupings
* The plots will use the group labels, therefore make sure these are clear and complete
local grouping_var = "grouping"
*local grouping_var = "" // uncomment for no groups

** Color for the groups:
* we preset 3 colors, add more if needed:
local color_1 = "ebblue%30"
local color_2 = "blue%30"
local color_3 = "green%30"

***** END OF TO BE ADJUSTED BY THE USER ********




***** TO BE ADJUSTED ONLY  BY ADVANCED USERS ********/
** As a user you should not modify the rows below.
** Only do so, if you are confident on what you are doing. 
 
 
 
 * load file
 use `ds_filename', replace
 
 * create sub-folder if not existent:
 capture mkdir "`sf'"
 
 
 * Identify groups:
 if "`grouping_var'" !="" {
	
	levelsof `grouping_var', local(group_levels)
	preserve
	drop if `grouping_var' == .
	 
 }
 
 use data_cleaned_LI, replace

local var_list = "total_hh_income_2018"

foreach var in `var_list' {	

	* ticks_x
	qui: sum `var'
	if r(max) < =  2 {
		local w = 0.1
	} 
	else if r(max) < = 50 {
		local w = 1
	} 
	else if r(max) < = 100 {
		local w = 10
	}
	else if r(max) < = 500 {
		local w = 25
	}
	else if r(max) < = 1000 {
		local w = 50
	}
	else if r(max) < = 2000 {
		local w = 100
	}
	else if r(max) < = 5000 {
		local w = 200
	}
	else {
		local w = 1000
	}
	disp "w is `w'"
	
	local ticks_x  = "xlabel(0(`w')`r(max)')"
	local ticks_x  = "xlabel(0(`w')13000)"
	
	
	local w_2 = `w'/2
	local extras = "at(att) bw(`w')"
	local att_steps = ceil(r(max)/(`w_2'))
	egen att = seq(), from(0) to(`att_steps')
	replace att = . if [_n]>`att_steps'
	replace att = att*(`w_2')
	
	
	
	* height
	qui: twoway__histogram_gen `var', gen(height_1 bin_1) frac w(`w') start(0)
	qui: sum height_1
	local h =  round(r(max),0.01)
	qui: drop height_1 bin_1
	
	* ticks y
	local n_ticks = round(`h'/0.01)
	local ticks_y = `"ylabel(0 "0" "'
	forvalues i = 1(1)`n_ticks'{
		local t_y = `i'*0.01
		local t_y_perc = round(`i'*0.01*100)
		
		local ticks_y = `"`ticks_y' `t_y' "`t_y_perc'" "'
	}
	local ticks_y = `"`ticks_y' )"'
	
	
	capture drop x_`var'* y_`var'*
	forvalues g = 1/3{
		kdensity `var' if grouping == `g' , gen(x_`var'_`g' y_`var'_`g') nograph kernel(gaus) `extras'
		replace y_`var'_`g' = y_`var'_`g'*`r(scale)'
		qui: sum y_`var'_`g'
		local max_`g' = `r(max)'
	}
	kdensity `var' , gen(x_`var' y_`var') nograph kernel(gaus) `extras'
	replace y_`var' = y_`var'*`r(scale)'
	qui: sum y_`var'
	local max_tot = `r(max)'
	
	local h =  round(max(`max_1',`max_2',`max_3',`max_tot'),0.01) 
	local h = 0.15
	local height = `h'
	
	* ticks y
	local n_ticks = round(`h'/0.01)
	local ticks_y = `"ylabel(0 "0" "'
	forvalues i = 1(1)`n_ticks'{
		local t_y = `i'*0.01
		local t_y_perc = round(`i'*0.01*100)
		
		local ticks_y = `"`ticks_y' `t_y' "`t_y_perc'" "'
	}
	local ticks_y = `"`ticks_y' )"'
	
	* 1 "Male, typical " 2 "Male, large" 3 "Female"
	
	local this_var: variable label `var'
	************
	qui: sum `var' if  grouping == 1, det
	local Note = "N = `r(N)'"
	local Note = "`Note', bin size = `w_2'"
	local this_mean = `r(mean)'
	local this_median = `r(p50)'
	qui: sum y_total_hh_income_2018_1, det
	*local height = 0.0004 //round(`r(max)',0.0001)
	local li_benchmark = 4742
	qui: sum li_benchmark_achieved if grouping == 1
	local share_li = round((`r(mean)')*100,0.1)
	local share_li = ustrleft(string(`share_li'),4) + "%"

	line y_`var'_1 x_`var'_1, color(ebblue%30) recast(area) ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
	legend(label( 1 "Male-headed, typical") label(2 "Living Income Benchmark") label(3 "mean") label(4 "median"))  || ///
	pci 0 `li_benchmark' `height' `li_benchmark', color(red) || ///
	pci 0 `this_mean' `height' `this_mean', color(blue) || ///
	pci 0 `this_median' `height' `this_median', color(green) ///
	xtitle("`this_var'") ///
	text(`height' `li_benchmark' "`share_li'", place(right))
	
	graph export Density_plots_fraction/`var'_living_income_bechmark_TYPICAL.png, width(1000) replace
	
	local li_benchmark_MHT = `li_benchmark'
	local share_li_MHT = "`share_li'" + " (MH, Typical)"
	
	************
	qui: sum `var' if  grouping == 2, det
	local Note = "N = `r(N)'"
	local Note = "`Note', bin size = `w_2'"
	local this_mean = `r(mean)'
	local this_median = `r(p50)'
	qui: sum y_total_hh_income_2018_2, det
	*local height = 0.0004 //round(`r(max)',0.0001)*1.5
	local li_benchmark = 5123
	qui: sum li_benchmark_achieved if grouping == 2
	local share_li = round((`r(mean)')*100,0.1)
	local share_li = ustrleft(string(`share_li'),4) + "%"
	
	line y_`var'_2 x_`var'_2, color(blue%30) recast(area) ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y' xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
	legend(label( 1 "Male-headed, large") label(2 "Living Income Benchmark") label(3 "mean") label(4 "median")) || ///
	pci 0 `li_benchmark' `height' `li_benchmark', color(red) || ///
	pci 0 `this_mean' `height' `this_mean', color(blue) || ///
	pci 0 `this_median' `height' `this_median', color(green) ///
	xtitle("`this_var'") ///
	text(`height' `li_benchmark' "`share_li'", place(right))
	
	graph export Density_plots_fraction/`var'_living_income_bechmark_MALE_LARGE.png, width(1000) replace
	
	local li_benchmark_MHL = `li_benchmark'
	local share_li_MHL = "`share_li'" + " (MH, large)"

	
	************
	qui: sum `var' if  grouping == 3, det
	local Note = "N = `r(N)'"
	local Note = "`Note', bin size = `w_2'"
	local this_mean = `r(mean)'
	local this_median = `r(p50)'
	qui: sum y_total_hh_income_2018_3, det
	*local height = 0.0004 //round(`r(max)',0.0001)
	local li_benchmark = 4001
	qui: sum li_benchmark_achieved if grouping == 3
	local share_li = round((`r(mean)')*100,0.1)
	local share_li = ustrleft(string(`share_li'),4) + "%"
	
	line y_`var'_3 x_`var'_3, color(green%30) recast(area) ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y' xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
	legend(label( 1 "Female-headed") label(2 "Living Income Benchmark") label(3 "mean") label(4 "median")) || ///
	pci 0 `li_benchmark' `height' `li_benchmark', color(red) || ///
	pci 0 `this_mean' `height' `this_mean', color(blue) || ///
	pci 0 `this_median' `height' `this_median', color(green) ///
	xtitle("`this_var'") ///
	text(`height' `li_benchmark' "`share_li'", place(right))
	
	graph export Density_plots_fraction/`var'_living_income_bechmark_FEMALE.png, width(1000) replace
	
	local li_benchmark_FH = `li_benchmark'
	local share_li_FH = "`share_li'" + " (FH)"
	**************
	** All together
	local Note = ""
	qui: sum `var' 
	local Note = "N (All) = `r(N)'"
	
	qui: sum `var' if  grouping == 1
	local Note = "`Note', N (Male, typical) = `r(N)'"
	
	qui: sum `var' if  grouping == 2
	local Note = "`Note', N (Male, large) = `r(N)'"
	
	qui: sum `var' if grouping == 3
	local Note = "`Note', N (Female) = `r(N)'"
	
	local Note = "`Note', bin size = `w_2'"
	
	local hMHT = `height' - 0.02
	local hMHL = `hMHT' - 0.02
	* 1 "Male, small" 2 "Male, large" 3 "Female"
	line y_`var' x_`var',   /// 
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xtitle("Estimated total household income (USD/year/household)") ///
	xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
	legend(label( 1 "All") label( 2 "Male-headed, typical") label( 3 "Male-headed, large") label( 4 "Female-headed") order(1 2 3 4)) || ///
	line y_`var'_1 x_`var'_1, color(ebblue%30) recast(area)  || /// 
	line y_`var'_2 x_`var'_2, color(blue%30) recast(area) || ///
	line y_`var'_3 x_`var'_3, color(green%30) recast(area) || ///
	pci 0 `li_benchmark_MHT' `hMHT' `li_benchmark_MHT', color(ebblue%80) || ///
	pci 0 `li_benchmark_MHL' `hMHL' `li_benchmark_MHL', color(blue%80) || ///
	pci 0 `li_benchmark_FH' `height' `li_benchmark_FH', color(green%80)  ///
	text(`hMHT' `li_benchmark_MHT' "Living Income Male-headed, typical", size(small) place(right) box margin(1 1 1 1) fcolor(ebblue%30))  /// 
	text(`hMHL' `li_benchmark_MHL' "Living Income Male-headed, large", size(small)  place(right) box margin(1 1 1 1) fcolor(blue%30))  ///
	text(`height' `li_benchmark_FH' "Living Income Female-headed", size(small)  place(right) box margin(1 1 1 1) fcolor(green%30))
	
	graph export Density_plots_fraction/`var'_living_income_bechmark.png, width(1000) replace
	
	*************
	
	drop x_`var'* y_`var'*
	
	
	
}

