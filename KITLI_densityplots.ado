/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata ado-file produces density (kernel smoothened) plots as fractions about 
the distribution of underlying variables for the indication of the household income.

It produces graphs similar to what can be seen at:
https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf
https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf


It assumes variables have already been calculated. 
If not, please check do-files: KITLI_incomecalculations.ado

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
capture program drop KITLI_densityplots
program define KITLI_densityplots, sortpreserve
	syntax varlist(numeric) [if] [in], ///
	[grouping_var(varname numeric) ///
	hard_min(string) ///
	hard_max(string) ///
	ytitle(string) ///
	colors(string) ///
	subfolder(string) ///
	nosave]
	

	** mark if and in
	marksample touse, novarlist


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
	 
	 
	 * Identify groups:
	 if "`grouping_var'" !="" {
		
		qui: levelsof `grouping_var' if `touse', local(group_levels)
		 
	 }
	 
	* Create regular density plots
	foreach var in `varlist' {	


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
	    qui: egen `temp_att' = seq(), from(0) to(`att_steps') // place holder for the steps
	    qui: replace `temp_att' = . if [_n]>`att_steps'
	    qui: replace `temp_att' = `temp_att'*(`w_2') // replace for the actual value of the step
	 	
		** Prepare additional options to be passed to be kernel computation function
		** for details type 
		** help kdensity
	    local extras = "at(`temp_att') bw(`w')"
			    
		* Prepare global note and labels:
		qui: sum `var'  if `touse'
		local Note = `""N (All) = `r(N)'""'
		local labels_cmd = `"label( 1 "All") "'
		
		* Append group information:
		if "`grouping_var'" !="" {
			local counter = 2
			foreach group in `group_levels' {
			
				qui: sum `var' if  `grouping_var' == `group' & `touse'

				local group_label: label (`grouping_var') `group'
				
				local Note = `"`Note' "N (`group_label') = `r(N)'""'
				local labels_cmd = `"`labels_cmd' label( `counter' "`group_label'")"'
				local counter = `counter'+1
				
			}
		
		}
		
		local Note = `"`Note' "bin size = `w_2'""'
		
		local current_max = 0
		local all_colors = "`colors'"
		local all_hard_min = "`hard_min'"
		local all_hard_max = "`hard_max'"
		** Compute kernels of each group
		if "`grouping_var'" !="" {
			local group_graph = ""
			local counter = 1
			foreach group in `group_levels' {
				
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

				* read min and max:
				if "`hard_min'" != "" | "`hard_max'" != "" {

					gettoken this_min all_hard_min: all_hard_min, parse("|")
					
					if "`this_min'" == "|" {
						gettoken this_min all_hard_min: all_hard_min, parse("|")
					}

					gettoken this_max all_hard_max: all_hard_max, parse("|")

					if "`this_max'" == "|"{
						gettoken this_max all_hard_max: all_hard_max, parse("|")
					}
					
					local min_max = ""
					if real("`this_min'")!=. | real("`this_max'")!=. {
						local min_max = "if "
						
						if real("`this_min'")!=. {
						
							local min_max = "`min_max' `temp_x_`group''>=`this_min' "
							
							if real("`this_max'")!=. { 
								local min_max = "`min_max' & "
							}
						}
						
						if real("`this_max'")!=. {
						
							local min_max = "`min_max' `temp_x_`group''<=`this_max' "
							
						}
					}
				}
				else {
					local min_max = ""
				}

				local group_graph = "`group_graph' || line `temp_y_`group'' `temp_x_`group'' `min_max', color(`this_color') recast(area)"
				local counter = `counter'+1
				
			}
		} 
		else {
			gettoken this_color all_colors: all_colors, parse("|")

			* read min and max:
			if "`hard_min'" != "" | "`hard_max'" != "" {

				gettoken this_min all_hard_min: all_hard_min, parse("|")
				
				if "`this_min'" == "|" {
					gettoken this_min all_hard_min: all_hard_min, parse("|")
				}

				gettoken this_max all_hard_max: all_hard_max, parse("|")

				if "`this_max'" == "|"{
					gettoken this_max all_hard_max: all_hard_max, parse("|")
				}
				
				local min_max = ""
				if real("`this_min'")!=. | real("`this_max'")!=. {
					local min_max = "if "
					
					if real("`this_min'")!=. {
					
						local min_max = "`min_max' `temp_x'>=`this_min' "
						
						if real("`this_max'")!=. { 
							local min_max = "`min_max' & "
						}
					}
					
					if real("`this_max'")!=. {
					
						local min_max = "`min_max' `temp_x'<=`this_max' "
						
					}
				}
			}
			else {
				local min_max = ""
			}


			local min_max_all =  "`min_max'"
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
				
		* Generate main graph
		line `temp_y' `temp_x' `min_max_all',   /// 
		legend(`labels_cmd') ///
		ytitle("`ytitle'") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note(`Note') graphregion(color(white)) `group_graph'
		
		* save graph
		if "`save'" != "nosave" {
			graph export "`subfolder'`var'_density_plot.png", width(1000) replace
		}

		drop `temp_att'
		
		
		
	}

end
