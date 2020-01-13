/*****************************************************************************
LIVING INCOME CALCULATIONS AND OUTPUTS

This stata utiliy ado-file performs inputation of values to assist in 
the LI CoP calculations.

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
capture program drop KITLI_inputations
program define KITLI_inputations, sortpreserve
	syntax  varlist(numeric) [if] [in], ///
	[grouping_var(varname numeric) ///
	generate(string) ///
	replace] 


	** check **
	if "`generate'" != "" & "`replace'" != "" {
            di as err "options generate and replace are mutually exclusive"
            exit 198
    }

    if "`generate'" == "" & "`replace'" == "" {
            di as err "must specify either generate or replace option"
            exit 198
    }

	
	** mark if and in
	marksample touse, novarlist


	* Identify groups:
	if "`grouping_var'" !="" {
		
		qui: levelsof `grouping_var' if `touse', local(group_levels)
		 
	}


	* Prepare variables
	if "`generate'" != "" {
		foreach var in `varlist'{
			qui: generate `generate'`var' = `var'
			qui: order `generate'`var', after(`var')
			local original_label: variable label  `var'
			qui: label variable `generate'`var' "(Inputed) `original_label'"
		}
	}


	* Run inputation:
	if "`grouping_var'" !="" {
		foreach group in `group_levels' {
			local group_label: label (`grouping_var') `group'
			foreach var in `varlist'{
					qui: sum `var' if grouping == `group' & `touse', det
					disp "Input values for `var', group `group_label'"
					replace `generate'`var' = `r(p50)' if grouping == `group' & `var' == . 
					note `generate'`var': Missing values for `group_label' inputed as `r(p50)'
			}
		}
	}
	else {
			foreach var in `varlist'{
					qui: sum `var' if `touse', det
					disp "Input values for `var'"
					replace `generate'`var' = `r(p50)' if  `var' == . 
					note `generate'`var': Missing values for `group_label' inputed as `r(p50)'
			}
	}


end
