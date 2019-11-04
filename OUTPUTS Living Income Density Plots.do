/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces density (kernel smoothened) plots as fractions about 
the distribution of underlying variables for the indication of the household income.

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
31/10/2019

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
* The plots will use the variable labels, therefore make sure these are clear and complete

* This list is for variables to which the smoothening plot applies
local var_list_regular = "prod_total_last_kg_ha revenue_usdha_2018 li_inputs_usdha_2018 li_hired_usdha_2018 total_income_2018 total_hh_income_2018"

* This list is for variables to which hard limits need to be set, for example if the grouping variable is defined by these variables
* you can leave it empty if not needed
* you also need to define min and max for each group, separated by "|"
local var_list_special = "cocoa_land_used_morethan5_ha"
local var_list_special_min = "   | 4 | " // this mean second group has a minimum of 4
local var_list_special_max = " 4 |   | " // this mean first  group has a maximum of 4
*local var_list_special = "" // uncomment for no special case

* Grouping variable, replace by an empty string for no groupings
* The plots will use the group labels, therefore make sure these are clear and complete
local grouping_var = "grouping"
*local grouping_var = "" // uncomment for no groups

** Color for the groups:
* we preset 3 colors, add more if needed, with increasing integer numbers:
* %30 refers to 30% transparency
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
 
* Create regular density plots
foreach var in `var_list_regular' {	


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
	local Note = `""N (All) = `r(N)'""'
	local labels_cmd = `"label( 1 "All") "'
	
	* Append group information:
	if "`grouping_var'" !="" {
		local counter = 2
		foreach group in `group_levels' {
		
			qui: sum `var' if  `grouping_var' == `group'

			local group_label: label (`grouping_var') `group'
			
			local Note = `"`Note' "N (`group_label') = `r(N)'""'
			local labels_cmd = `"`labels_cmd' label( `counter' "`group_label'")"'
			local counter = `counter'+1
			
		}
	
	}
	
	local Note = `"`Note' "bin size = `w_2'""'
	
	capture drop x_`var'* y_`var'*
	
	local current_max = 0
	** Compute kernels of each group
	if "`grouping_var'" !="" {
			local group_graph = ""
			local counter = 1
			foreach group in `group_levels' {
			
				kdensity `var' if `grouping_var' == `group', gen(x_`var'_`group' y_`var'_`group') nograph kernel(gaus) `extras'
				replace y_`var'_`group' = y_`var'_`group'*`r(scale)'
				qui: sum y_`var'_`group'
				local current_max = max(`r(max)',`current_max')
				local group_graph = "`group_graph' || line y_`var'_`group' x_`var'_`group', color(`color_`counter'') recast(area)"
				local counter = `counter'+1
			
		}
	} 
	else {
		local group_graph = "`group_graph' color(`color_1') recast(area) lcolor(black)"
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
			
	* Generate main graph
	line y_`var' x_`var',   /// 
	legend(`labels_cmd') ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note(`Note') graphregion(color(white)) `group_graph'
	
	graph export "`sf'`var'_density_plot.png", width(1000) replace
	
	drop x_`var'* y_`var'* att
	
	
	
}


* Create density plots with hard max and/or min
* This block is identical to the above, except that it incorporates the max and min limits
foreach var in `var_list_special' {	


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
	local Note = `""N (All) = `r(N)'""'
	local labels_cmd = `"label( 1 "All") "'
	
	* Append group information:
	if "`grouping_var'" !="" {
		local counter = 2
		foreach group in `group_levels' {
		
			qui: sum `var' if  `grouping_var' == `group'

			local group_label: label (`grouping_var') `group'
			
			local Note = `"`Note' "N (`group_label') = `r(N)'""'
			local labels_cmd = `"`labels_cmd' label( `counter' "`group_label'")"'
			local counter = `counter'+1
			
		}
	
	}
	
	local Note = `"`Note' "bin size = `w_2'""'
	
	capture drop x_`var'* y_`var'*
	
	local current_max = 0
	** Compute kernels of each group
	if "`grouping_var'" !="" {
			local group_graph = ""
			local counter = 1
			foreach group in `group_levels' {
			
				* read min and max:
				gettoken this_min var_list_special_min: var_list_special_min, parse("|")
				gettoken this_max var_list_special_max: var_list_special_max, parse("|")
				
				local min_max = ""
				if real("`this_min'")!=. | real("`this_max'")!=. {
					local min_max = "if "
					
					if real("`this_min'")!=. {
					
						local min_max = "`min_max' x_`var'_`group'>=`this_min' "
						
						if real("`this_max'")!=. { 
							local min_max = "`min_max' & "
						}
					}
					
					if real("`this_max'")!=. {
					
						local min_max = "`min_max' x_`var'_`group'<=`this_max' "
						
					}
				}
				
				
				kdensity `var' if `grouping_var' == `group', gen(x_`var'_`group' y_`var'_`group') nograph kernel(gaus) `extras'
				replace y_`var'_`group' = y_`var'_`group'*`r(scale)'
				qui: sum y_`var'_`group'
				local current_max = max(`r(max)',`current_max')
				local group_graph = "`group_graph' || line y_`var'_`group' x_`var'_`group' `min_max', color(`color_`counter'') recast(area)"
				local counter = `counter'+1
			

		}
	} 
	else {
		local group_graph = "`group_graph' color(`color_1') recast(area) lcolor(black)"
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
			
	* Generate main graph
	line y_`var' x_`var',   /// 
	legend(`labels_cmd') ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note(`Note') graphregion(color(white)) `group_graph'
	
	graph export "`sf'`var'_density_plot.png", width(1000) replace
	
	drop x_`var'* y_`var'* att
	
	
	
}

restore
