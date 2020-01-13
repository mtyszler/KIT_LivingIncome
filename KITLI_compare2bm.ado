/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces density (kernel smoothened) plots as fractions about 
the total household income with the goal of comparing to the benchmark value

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
1/11/2019

*****************************************************************************/

version 15.1 
capture program drop KITLI_compare2bm
program define KITLI_compare2bm, sortpreserve
	syntax varname(numeric) [if] [in], ///
	bm_achieved(varname numeric) ///
	total_hh_income(varname numeric) ///
	[grouping_var(varname numeric) ///
	ytitle(string) ///
	spacing(real 0.02) ///
	colors(string) ///
	subfolder(string) ///
	nosave]
	

	** mark if and in
	marksample touse, novarlist


	** rename varlist:
	local li_benchmark = "`varlist'"

	** load defaults in case optional arguments are skipped:	
	capture confirm existence `colors'
	if _rc == 6 {
		local colors = "ebblue%30 | blue%30 | green%30 | orange%30"
	}

	capture confirm existence `ytitle'
	if _rc == 6 {
		local ytitle = "Proportion of households (%)"
	}

 	*** create tempvars
	tempvar temp_att 
 
	* create sub-folder if not existent:
	if "`subfolder'" != "" {
		if ustrright("`subfolder'", 1) != "/" {
			local subfolder = "`subfolder'" + "/"
		}
		capture mkdir "`subfolder'"
	}
	 disp "`subfolder'"
	 
	 * Identify groups:
	 if "`grouping_var'" !="" {
		
		qui: levelsof `grouping_var' if `touse', local(group_levels)
		 
	 }
	 

	local var = "`total_hh_income'"
	local this_var: variable label `var'

	* Define bin size and steps for the density calculation
	qui: sum `var' if `touse'
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
	egen `temp_att' = seq(), from(0) to(`att_steps') // place holder for the steps
	qui: replace `temp_att' = . if [_n]>`att_steps'
	qui: replace `temp_att' = `temp_att'*(`w_2') // replace for the actual value of the step

	** Prepare additional options to be passed to be kernel computation function
	** for details type 
	** help kdensity
	local extras = "at(`temp_att') bw(`w')"


	* Prepare global note and labels:
	qui: sum `var'  if `touse'
	local Note_full = `""N (All) = `r(N)'""'
	local labels_cmd = `"label( 1 "All") "'

	* Append group information:
	if "`grouping_var'" !="" {
		local counter = 2
		local cmd_order = "order (1 "
		foreach group in `group_levels' {
		
			qui: sum `var' if  `grouping_var' == `group' & `touse'

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

	local current_max = 0
	local all_colors = "`colors'"
	** Compute kernels of each group
	if "`grouping_var'" !="" {
		local group_graph = ""
		local counter = 1
		foreach group in `group_levels' {
		
			local group_label: label (`grouping_var') `group'
			
			capture drop temp_x_`group' temp_y_`group'	
			capture tempvar temp_x_`group' temp_y_`group'
			kdensity `var' if `grouping_var' == `group' & `touse', gen(`temp_x_`group'' `temp_y_`group'') nograph kernel(gaus) `extras'
			qui: replace `temp_y_`group'' = `temp_y_`group''*`r(scale)'
			qui: sum `temp_y_`group''
			local current_max = max(`r(max)',`current_max')

			gettoken this_color all_colors: all_colors, parse("|")
			if "`this_color'" == "|" {
				gettoken this_color all_colors: all_colors, parse("|")
			}

			local group_graph = "`group_graph' || line `temp_y_`group'' `temp_x_`group'', color(`this_color') recast(area)"
			local counter = `counter'+1
		}
	} 
	else {
		gettoken this_color all_colors: all_colors, parse("|")
		local group_graph = " color(`this_color') recast(area) lcolor(black)"
	}


	* Compute kernel for the whole sample
	capture drop temp_x temp_y
	capture tempvar temp_x temp_y
	kdensity `var' if `touse' , gen(`temp_x' `temp_y') nograph kernel(gaus) `extras'
	qui: replace `temp_y' = `temp_y'*`r(scale)'
	qui: sum `temp_y'

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

	local all_colors = "`colors'"
	* Genereate graphs per group:
	if "`grouping_var'" !="" {
		local all_colors = "`colors'"
		local counter = 1
		foreach group in `group_levels' {
			local group_label: label (`grouping_var') `group'
			
			qui: sum `var' if  grouping == `group' & `touse', det
			local Note = "N = `r(N)'"
			local Note = "`Note', bin size = `w_2'"
			local this_mean = `r(mean)'
			local this_median = `r(p50)'

			qui: sum `bm_achieved' if `grouping_var' == `group' & `touse'
			local share_li = round((`r(mean)')*100,0.1)
			local share_li_`counter' = ustrleft(string(`share_li'),4) + "%"

			qui: sum `li_benchmark' if `grouping_var' == `group' & `touse'
			local li_benchmark_`counter' = round(`r(mean)',1)

			gettoken this_color all_colors: all_colors, parse("|")
			if "`this_color'" == "|" {
				gettoken this_color all_colors: all_colors, parse("|")
			}
			
			line `temp_y_`group'' `temp_x_`group'', color(`this_color') recast(area) ///
			ytitle("`ytitle'") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) ///
			legend(label( 1 "`group_label'") label(2 "Living Income Benchmark") label(3 "mean") label(4 "median"))  || ///
			pci 0 `li_benchmark_`counter'' `h' `li_benchmark_`counter'', color(red) || ///
			pci 0 `this_mean' `h' `this_mean', color(blue) || ///
			pci 0 `this_median' `h' `this_median', color(green) ///
			xtitle("`this_var'") ///
			text(`h' `li_benchmark_`counter'' "`share_li_`counter'' above the benchmark", place(right))
			
			if "`save'" != "nosave" {
				graph export "`subfolder'`var'_living_income_bechmark `group_label'.png", width(1000) replace
			}

			local counter = `counter'+1
		}
	}
	else {
		qui: sum `li_benchmark' if  `touse'
		local li_benchmark_1 = round(`r(mean)',1)
	}


	** All together
	** Decide on the heights, ordering by benchmark value:
	if "`grouping_var'" !="" {
		tempvar temp_order_height temp_order_height_counter current_sort
		local counter = 1
		qui: gen `temp_order_height' = .
		qui: gen `temp_order_height_counter' = .
		foreach group in `group_levels' {

			replace `temp_order_height' =  `li_benchmark_`counter'' in `counter'
			replace `temp_order_height_counter' =  `counter' in `counter'
			local counter = `counter'+1
			
		}

		gen `current_sort' = [_n]
		sort `temp_order_height'

		local counter = 1
		foreach group in `group_levels' {

			if `counter' == 1 {
				local this_counter = `temp_order_height_counter'[`counter']
				local h_`this_counter'  = `h'

			} 
			else {
				local this_counter = `temp_order_height_counter'[`counter']
				local previous_counter = `temp_order_height_counter'[`counter'-1]
				local h_`this_counter'  = `h_`previous_counter'' - `spacing'
			}
			
			local counter = `counter'+1
				
		}

		sort `current_sort'
	}
	else {
		local h_1 = `h'
	}

	local all_colors = "`colors'"
	if "`grouping_var'" !="" {
			local group_bm_line = ""
			local group_bm_box = ""
			local counter = 1
			foreach group in `group_levels' {
			
				local group_label: label (`grouping_var') `group'
					
				gettoken this_color all_colors: all_colors, parse("|")
				if "`this_color'" == "|" {
					gettoken this_color all_colors: all_colors, parse("|")
				}
				local group_bm_line = "`group_bm_line' || pci 0 `li_benchmark_`counter'' `h_`counter'' `li_benchmark_`counter'', color(`this_color')"
				local group_bm_box = `"`group_bm_box' text(`h_`counter'' `li_benchmark_`counter'' "Living Income `group_label': `share_li_`counter'' above", size(small)  place(right) box margin(1 1 1 1) fcolor(`this_color'))"'
			
				local counter = `counter'+1
		
		
			
		}
	} 
	else {
		gettoken this_color all_colors: all_colors, parse("|")
		local group_bm_line = " || pci 0 `li_benchmark_1' `h_1' `li_benchmark_1', color(`this_color')"
		local group_bm_box = `" text(`h_1' `li_benchmark_1' "Living Income Benchmark", size(small)  place(right) box margin(1 1 1 1) fcolor(`this_color'))"'	
	}


	line `temp_y' `temp_x',   /// 
	ytitle("`ytitle'") `ticks_x' `ticks_y'  xtitle("`this_var'") ///
	xlabel(, labsize(small)) note(`Note_full') graphregion(color(white)) ///
	legend(`labels_cmd') ///
	`group_graph' ///
	`group_bm_line' ///
	`group_bm_box' 

	if "`save'" != "nosave" {
		graph export "`subfolder'`var'_living_income_bechmark.png", width(1000) replace
	}

end
