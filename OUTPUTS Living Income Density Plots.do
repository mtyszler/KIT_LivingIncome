/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata do-file produces density plots as fractions about the distribution
of underlying variables for the indication of the household income.


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


 use data_cleaned_LI, replace

 local var_list = "revenue_total_2018 revenue_usdha_2018"
 cocoa_land_used_ha cocoa_land_used_morethan5_ha prod_total_last_kg_ha prod_total_last_kg li_costs_usdhh_2018 li_inputs_usdhh_2018 li_hired_usdhh_2018 li_costs_usdha_2018 li_inputs_usdha_2018 li_hired_usdha_2018 total_hh_income_2018 total_income_2018"
*local var_list = "li_cocoa_inputs_usdha_2018"
*local var_list = "total_hh_income_2018"

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
	local n_ticks = round(`h'/0.1)+1
	local ticks_y = `"ylabel(0 "0" "'
	forvalues i = 1(1)`n_ticks'{
		local t_y = `i'*0.1
		local t_y_perc = round(`i'*0.1*100)
		
		local ticks_y = `"`ticks_y' `t_y' "`t_y_perc'" "'
	}
	local ticks_y = `"`ticks_y' )"'
	
	
	local title = "Histogram"
	
	local colors = "..\histogram_cocoa_blue"
		
	qui: sum `var' 
	local N = r(N)
	
	
	if `N'>0 {
	
		
		KIT_histogram_alt `var' , ///
		width(`w') height(`h') /// 
		additional_options(`ticks_x' `ticks_y' /// 
		 start(0) ///
		play(`colors') ///
		note("N = `N'") ///
		)
	}

	graph export Density_plots/`var'_`title'.png, width(1000) replace
	
	local Note = ""
	qui: sum `var' 
	local Note = "N (All) = `r(N)'"
	
	qui: sum `var' if  grouping == 1
	local Note = "`Note', N (Male, typical) = `r(N)'"
	
	qui: sum `var' if grouping == 2
	local Note = "`Note', N (Male, large) = `r(N)'"
	
	qui: sum `var' if grouping == 3
	local Note = "`Note', N (Female) = `r(N)'"
	
	local Note = "`Note', bin size = `w_2'"
	
		capture drop x_`var'* y_`var'*
	forvalues g = 1/3{
		kdensity `var' if grouping == `g', gen(x_`var'_`g' y_`var'_`g') nograph kernel(gaus) `extras'
		replace y_`var'_`g' = y_`var'_`g'*`r(scale)'
		qui: sum y_`var'_`g'
		local max_`g' = `r(max)'
	}
	kdensity `var' , gen(x_`var' y_`var') nograph kernel(gaus) `extras'
	replace y_`var' = y_`var'*`r(scale)'
	qui: sum y_`var'
	local max_tot = `r(max)'
	
	local h =  round(max(`max_1',`max_2',`max_3',`max_tot'),0.01) 
	
	/*
	local h = 0.1
	if "`var'"=="li_cocoa_hired_usdha_2018"{
		local h = 0.16
	}
	*/
	
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
			
	* 1 "Male, small" 2 "Male, large" 3 "Female"
	line y_`var' x_`var',   /// 
	legend(label( 1 "All") label( 2 "Male-headed, typical") label( 3 "Male-headed, large") label( 4 "Female-headed")) ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) || ///
	line y_`var'_1 x_`var'_1, color(ebblue%30) recast(area)  || /// 
	line y_`var'_2 x_`var'_2, color(blue%30) recast(area) || ///
	line y_`var'_3 x_`var'_3, color(green%30) recast(area)
	
	graph export Density_plots_fraction/`var'_density_plot.png, width(1000) replace
	
	drop x_`var'* y_`var'* att
	
	
	
}

 local var_list = "cocoa_land_used_morethan5_ha"


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
	
	local w_2 = 0.5
	local extras = "at(att) bw(1)"
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
	local n_ticks = round(`h'/0.1)+1
	local ticks_y = `"ylabel(0 "0" "'
	forvalues i = 1(1)`n_ticks'{
		local t_y = `i'*0.1
		local t_y_perc = round(`i'*0.1*100)
		
		local ticks_y = `"`ticks_y' `t_y' "`t_y_perc'" "'
	}
	local ticks_y = `"`ticks_y' )"'
	
	
	local title = "Histogram"
	
	local colors = "..\histogram_cocoa_blue"
		
	qui: sum `var' 
	local N = r(N)
	
	
	if `N'>0 {
	
		
		KIT_histogram_alt `var'  , ///
		width(`w') height(`h') /// 
		additional_options(`ticks_x' `ticks_y' /// 
		 start(0) ///
		play(`colors') ///
		note("N = `N'") ///
		)
	}

	graph export Density_plots/`var'_`title'.png, width(1000) replace
	
	local Note = ""
	qui: sum `var' 
	local Note = "N (All) = `r(N)'"
	
	qui: sum `var' if grouping == 1
	local Note = "`Note', N (Male, typical) = `r(N)'"
	
	qui: sum `var' if  grouping == 2
	local Note = "`Note', N (Male, large) = `r(N)'"
	
	qui: sum `var' if  grouping == 3
	local Note = "`Note', N (Female) = `r(N)'"
	
	local Note = "`Note', bin size = `w_2'"
	
		capture drop x_`var'* y_`var'*
	forvalues g = 1/3{
		kdensity `var' if grouping == `g', gen(x_`var'_`g' y_`var'_`g') nograph kernel(gaus)  `extras'
		replace y_`var'_`g' = y_`var'_`g'*`r(scale)'
		qui: sum y_`var'_`g'
		local max_`g' = `r(max)'
	}
	kdensity `var' , gen(x_`var' y_`var') nograph kernel(gaus) `extras'
	replace y_`var' = y_`var'*`r(scale)'
	qui: sum y_`var'
	local max_tot = `r(max)'
	
	local h =  round(max(`max_1',`max_2',`max_3',`max_tot'),0.01) 
	
	/*
	local h = 0.1
	if "`var'"=="li_cocoa_hired_usdha_2018"{
		local h = 0.16
	}
	*/
	
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
			
	* 1 "Male, small" 2 "Male, large" 3 "Female"
	line y_`var' x_`var',   /// 
	legend(label( 1 "All") label( 2 "Male-headed, typical") label( 3 "Male-headed, large") label( 4 "Female-headed")) ///
	ytitle("Proportion of households (%)") `ticks_x' `ticks_y'  xlabel(, labsize(small)) note("`Note'") graphregion(color(white)) || ///
	line y_`var'_1 x_`var'_1 if  x_`var'_1<=4, color(ebblue%30) recast(area)  || /// 
	line y_`var'_2 x_`var'_2 if  x_`var'_2>=4, color(blue%30) recast(area) || ///
	line y_`var'_3 x_`var'_3, color(green%30) recast(area)
	
	graph export Density_plots_fraction/`var'_density_plot.png, width(1000) replace
	
	drop x_`var'* y_`var'* att
	
	
	
}

