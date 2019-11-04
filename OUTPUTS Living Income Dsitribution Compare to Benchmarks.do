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

* This the income variables to which the smoothening plot applies
local total_hh_income = "total_hh_income"

* This indicates if the benchmark has been achieved
local bm_achieved = "li_benchmark_achieved"
* Values of the benchmark, per group, with increasing integer numbers in the order they appear:
* At least 1 benchmark is needed, if no grouping takes place
local li_benchmark_1 = 4742
local li_benchmark_2 = 5123
local li_benchmark_3 = 4001

* Grouping variable, replace by an empty string for no groupings
* The plots will use the group labels, therefore make sure these are clear and complete
local grouping_var = "grouping"
*local grouping_var = "" // uncomment for no groups

** Color for the groups:
* we preset 3 colors, add more if needed, with increasing integer numbers:
local color_1 = "ebblue%30"
local color_2 = "blue%30"
local color_3 = "green%30"

** Spacing between labels
* Increase if you want more space between the group labels in the final graph
local spacing = 0.02

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
	*preserve
	drop if `grouping_var' == .
	 
 }
 

local var = "`total_hh_income'"
local this_var: variable label `var'

* Define bin size and steps for the density calculation
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
local ticks_x  = "xlabel(0(`w')`r(max)')"

* Density bin size is defined as half step of the histogram-like bin size    
local w_2 = `w'/2
local att_steps = ceil(r(max)/(`w_2')) // number of steps needed
egen att = seq(), from(0) to(`att_steps') // place holder for the steps
replace att = . if [_n]>`att_steps'
replace att = att*(`w_2') // replace for the actual value of the step

** Prepare additional options to be passed to be kernel computation function
** for details type 
** help kdensity
local extras = "at(att) bw(`w')"


* Prepare global note and labels:
qui: sum `var' 
local Note_full = `""N (All) = `r(N)'""'
local labels_cmd = `"label( 1 "All") "'

* Append group information:
if "`grouping_var'" !="" {
	local counter = 2
	local cmd_order = "order (1 "
	foreach group in `group_levels' {
	
		qui: sum `var' if  `grouping_var' == `group'

		local group_label: label (`grouping_var') `group'
		
		local Note_full= `"`Note_full' "N (`group_label') = `r(N)'""'
		local labels_cmd = `"`labels_cmd' label( `counter' "`group_label'")"'
		local cmd_order = "`cmd_order' `counter'"
		local counter = `counter'+1
		
	}
	
	local cmd_order = "`cmd_order')"
	local labels_cmd = `"`labels_cmd' `cmd_order'"'
} 
else {
	local labels_cmd = `"label( 1 "All") order(1)"'
}

local Note_full = `"`Note_full' "bin size = `w_2'""'

capture drop x_`var'* y_`var'*

local current_max = 0
** Compute kernels of each group
if "`grouping_var'" !="" {
		local group_graph = ""
		local counter = 1
		foreach group in `group_levels' {
		
			local group_label: label (`grouping_var') `group'
		
			kdensity `var' if `grouping_var' == `group', gen(x_`var'_`group' y_`var'_`group') nograph kernel(gaus) `extras'
			replace y_`var'_`group' = y_`var'_`group'*`r(scale)'
			qui: sum y_`var'_`group'
			local current_max = max(`r(max)',`current_max')
			local group_graph = "`group_graph' || line y_`var'_`group' x_`var'_`group', color(`color_`counter'') recast(area)"
		
			local counter = `counter'+1
	
	
		
	}
} 
else {
	local group_graph = " color(`color_1') recast(area) lcolor(black)"
}


* Compute kernel for the whole sample
kdensity `var' , gen(x_`var' y_`var') nograph kernel(gaus) `extras'
replace y_`var' = y_`var'*`r(scale)'
qui: sum y_`var'
local current_max = max(`r(max)',`current_max')

local h =  round(`current_max',0.01) 


* ticks y
if `h'>0.16 {
	local ssize = 0.05
} 
else {
	local ssize = 0.01
}

local n_ticks = round(`h'/`ssize')
local ticks_y = `"ylabel(0 "0" "'
forvalues i = 1(1)`n_ticks'{
	local t_y = `i'*`ssize'
	local t_y_perc = round(`i'*`ssize'*100)
	
	local ticks_y = `"`ticks_y' `t_y' "`t_y_perc'" "'
}
local ticks_y = `"`ticks_y' )"'


* Genereate graphs per group:
if "`grouping_var'" !="" {
	local counter = 1
	foreach group in `group_levels' {
		local group_label: label (`grouping_var') `group'
		
		qui: sum `var' if  grouping == `group', det
		local Note = "N = `r(N)'"
		local Note = "`Note', bin size = `w_2'"
		local this_mean = `r(mean)'
		local this_median = `r(p50)'
		qui: sum y_`var'_1, det

		qui: sum `bm_achieved' if `grouping_var' == `group'
		local share_li = round((`r(mean)')*100,0.1)
		local share_li = ustrleft(string(`share_li'),4) + "%"
		
		line y_`var'_`group' x_`var'_`group', color(`color_`counter'') recast(area) ///
		ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
		legend(label( 1 "`group_label'") label(2 "Living Income Benchmark") label(3 "mean") label(4 "median"))  || ///
		pci 0 `li_benchmark_`counter'' `h' `li_benchmark_`counter'', color(red) || ///
		pci 0 `this_mean' `h' `this_mean', color(blue) || ///
		pci 0 `this_median' `h' `this_median', color(green) ///
		xtitle("`this_var'") ///
		text(`h' `li_benchmark_`counter'' "`share_li' above the benchmark", place(right))
		
		graph export "`sf'`var'_living_income_bechmark `group_label'.png", width(1000) replace
		
		local share_li_`group' = "`share_li'" + " (`group_label')"
		
		local counter = `counter'+1
	}
}


** All together
** Decide on the heights, ordering by benchmark value:
if "`grouping_var'" !="" {
	local counter = 1
	gen temp_order_height = .
	gen temp_order_height_counter = .
	foreach group in `group_levels' {

		replace temp_order_height =  `li_benchmark_`counter'' in `counter'
		replace temp_order_height_counter =  `counter' in `counter'
		local counter = `counter'+1
		
	}

	gen current_sort = [_n]
	sort temp_order_height

	local counter = 1
	foreach group in `group_levels' {

		if `counter' == 1 {
			local this_counter = temp_order_height_counter[`counter']
			local h_`this_counter'  = `h'

		} 
		else {
			local this_counter = temp_order_height_counter[`counter']
			local previous_counter = temp_order_height_counter[`counter'-1]
			local h_`this_counter'  = `h_`previous_counter'' - `spacing'
		}
		
		local counter = `counter'+1
			
	}

	drop temp_order_height_counter temp_order_height
	sort current_sort
	drop current_sort
}
else {
	local h_1 = li_benchmark_1
}


if "`grouping_var'" !="" {
		local group_bm_line = ""
		local group_bm_box = ""
		local counter = 1
		foreach group in `group_levels' {
		
			local group_label: label (`grouping_var') `group'
		
			
			local group_bm_line = "`group_bm_line' || pci 0 `li_benchmark_`counter'' `h_`counter'' `li_benchmark_`counter'', color(`color_`counter'')"
			local group_bm_box = `"`group_bm_box' text(`h_`counter'' `li_benchmark_`counter'' "Living Income `group_label'", size(small)  place(right) box margin(1 1 1 1) fcolor(`color_`counter''))"'
		
			local counter = `counter'+1
	
	
		
	}
} 
else {
*local group_graph = "`group_graph' color(`color_1') recast(area) lcolor(black)"
	local group_bm_line = " || pci 0 `li_benchmark_1' `h_1' `li_benchmark_1', color(`color_1')"
	local group_bm_box = `" text(`h_`counter'' `li_benchmark_`counter'' "Living Income Benchmark", size(small)  place(right) box margin(1 1 1 1) fcolor(`color_1'))"'	
}


line y_`var' x_`var',   /// 
ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xtitle("`this_var'") ///
xlabel(, labsize(small)) note(`Note_full') graphregion(color(white)) ///
legend(`labels_cmd') ///
`group_graph' ///
`group_bm_line' ///
`group_bm_box' 

graph export Density_plots_fraction/`var'_living_income_bechmark.png, width(1000) replace

*************

drop x_`var'* y_`var'* att
*restore
