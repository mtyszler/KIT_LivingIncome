{smcl}
{* *! version 0  31dec2019}{...}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Bar charts of the Gap to the Living Income Benchmark.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: KITLI_barcharts}
{it:li_benchmark} {ifin}, arguments

{synoptset 30 tabbed}{...}
{synopthdr:mandatory arguments}
{synoptline}

{synopt :{opth total_main_income:(varname)}} {varname} of total income from main source, for example main crop sales {p_end}
{synopt :{opth total_hh_income:(varname)}} {varname} of total household income {p_end}


{synopthdr:optional arguments}
{synoptline}

{syntab: Calculation}

{synopt :{cmd:median}} compute {help egen:medians} instead of {help mean} (default) {p_end}
{synopt :{cmd:as_share}} compute share of the benchmark value instead of absolute (default) {p_end}
{synopt :{opth food:(number)}} include value of food produced and consumed at home {p_end}

{syntab: (Optional) Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}


{syntab: Graph labels}

{synopt :{opth label_currency:(text)}} Text for currency name. Default "USD" {p_end}
{synopt :{opth label_main_income:(text)}} Text for main income. Default "Income from main crop" {p_end}
{synopt :{opth label_remaining_income:(text)}} Text for remaining income. Default "Other income" {p_end}


{syntab: Graph colors}
{synopt :{opth color_main:(text)}} Color of main source of income. Default "blue%30" {p_end}
{synopt :{opth color_remaining:(text)}} Color of remaining income. Default "ebblue%30" {p_end}
{synopt :{opth color_gap:(text)}} Color of the gap to the living income benchmark. Default "red%30" {p_end}
{synopt :{opth color_food:(text)}} Color of the intrinsic value of food consumed at home. Default "orange%30". Only in case {it:food} is defined {p_end}

{syntab: Graph exporting}

{synopt :{cmd:nosave}} does not save the generated graph (default behavior is to save) {p_end}
{synopt :{opth subfolder:(text)}} (relative) subfolder to save the graph. Default is the current folder {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd: KITLI_barcharts} produces bar charts of the Gap to the Living Income Benchmark, assuming there are two main sources of income.

{pstd} It produces graphs similar to what can be seen at:
{browse "https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf"}
{browse "https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf"}

{pstd} It computes, optionally per group, the average or median household and breaksdown its income into main income, other income, gap to the living income benchmark. Optionally it includes a fixed value
for the intrinsic value of food crops produced and consumed at home. 


{title:Arguments}

{dlgtab:Main}

{pmore}
{cmd:li_benchmark} {varname} which containts the living income benchmark value per observation.
{p_end}

{dlgtab:Mandatory}

{pmore}
{opth total_main_income:(varname)} {varname} of total income from main source, for example main crop sales. The graphs assume there is one main income source. 

{pmore}
{opth total_hh_income:(varname)} {varname} of total household income, including the main income source. 


{pmore}{it:{cmd:li_benchmark}, {opth total_main_income:(varname)} and {opth total_hh_income:(varname)} need to be in the same currency and unit (e.g., USD per household).}
{p_end}


{dlgtab:Calculation}
{pmore}
{cmd:median} changes the default behavior ({help mean}) and computes {help egen: medians}. {p_end}

{pmore}
{cmd:as_share} compute shares of the benchmark value instead of absolute (default), i.e. all bars are normalized to 100% of the benchmark value. {p_end}

{pmore}
{opth food:(number)} include value of food produced and consumed at home. This needs to be in the same currenty and unit as  
{it:{cmd:li_benchmark}, {opth total_main_income:(varname)} and {opth total_hh_income:(varname)}}
, and cannot change per group. {p_end}


{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, bar charts will have one bar per group. {p_end}


{dlgtab: Graph labels}
{pmore}
{opth label_currency:(text)} Text for currency name. If not specified,  {it:USD} is shown. {p_end}

{pmore}
{opth label_main_income:(text)} Text for main income. If not specified, {it:Income from main crop} is shown. {p_end}

{pmore}
{opth label_remaining_income:(text)} Text for remaining income. If not specified, {it:Other income}  is shown.  {p_end}


{dlgtab: Graph colors}
{pmore}{it:For more information see {help colorstyle}}

{pmore}
{opth color_main:(text)} Color of main source of income. Default "blue%30".  {p_end}

{pmore}
{opth color_remaining:(text)} Color of remaining income. Default "ebblue%30" {p_end}

{pmore}
{opth color_gap:(text)} Color of the gap to the living income benchmark. Default "red%30" {p_end}

{pmore}
{opth color_food:(text)} Color of the intrinsic value of food consumed at home. Default "orange%30". Only in case {it:food} is defined {p_end}


{dlgtab: Graph exporting}

{pmore}
{cmd:nosave} does not save the generated graph (default behavior is to save). Graph name will start with "bar_LI_gap" and will be followed by "mean" or "median", and include "as_share" and/or "food" as applicable. {p_end}

{pmore}
{opth subfolder:(text)} (relative) subfolder to save the graph. Default is the current folder. Please make sure name is correct and includes "/" as separator if needed. Folder will be created if necessary. {p_end}


{title:Examples}

{phang}Setup

{phang}{cmd:. use LI_example_data.dta, replace}{p_end}

{phang}Bar Chart by group, means

{phang}{cmd:. KITLI_barcharts benchmark_cluster,  total_main_income(total_income_2018) total_hh_income (total_hh_income_2018) grouping_var(grouping) subfolder("Bar_Charts")}{p_end}

{phang}Bar Chart by group, medians

{phang}{cmd:. KITLI_barcharts benchmark_cluster,  total_main_income(total_income_2018) total_hh_income (total_hh_income_2018) grouping_var(grouping) subfolder("Bar_Charts") median}{p_end}

{phang}Bar Chart by group, means as share

{phang}{cmd:. KITLI_barcharts benchmark_cluster,  total_main_income(total_income_2018) total_hh_income (total_hh_income_2018) grouping_var(grouping) subfolder("Bar_Charts") as_share}{p_end}

{phang}Bar Chart by group, medians as share

{phang}{cmd:. KITLI_barcharts benchmark_cluster,  total_main_income(total_income_2018) total_hh_income (total_hh_income_2018) grouping_var(grouping) subfolder("Bar_Charts") median as_share}{p_end}

{phang}Bar Chart by group, means with food value

{phang}{cmd:. KITLI_barcharts benchmark_cluster,  total_main_income(total_income_2018) total_hh_income (total_hh_income_2018) grouping_var(grouping) subfolder("Bar_Charts") food(450)}{p_end}

{phang}Bar Chart by group, means with food value as share

{phang}{cmd:. KITLI_barcharts benchmark_cluster,  total_main_income(total_income_2018) total_hh_income (total_hh_income_2018) grouping_var(grouping) subfolder("Bar_Charts") food(450) as_share}{p_end}


{title:Citation}
{phang}
{cmd:KITLI_barcharts} is not an official Stata command. It is a free contribution to the research community, like a paper.
Please cite it as such:{p_end}

{phang}
Tyszler, et al. (2019). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: {browse "include_later":m.tyszler@kit.nl} 
{p_end}

{phang}
If you have requests or suggestions, please do so at our repository:  {browse "https://bitbucket.org/kitimpactteam/living-income-calculations/"} {p_end}


{title:Authors}
{phang} Marcelo Tyszler {bf:{it: (Package maintainer)}}. Sustainable Economic Development and Gender, KIT Royal Tropical Institute, Netherlands. {browse "mailto:m.tyszler@kit.nl":m.tyszler@kit.nl} {p_end}

{phang} Carlos de los Rios. COSA.  {browse "mailto:cd@thecosa.org":cd@thecosa.org}{p_end}


{title:References}
{phang}
Bitbucket repository:  {browse "https://bitbucket.org/kitimpactteam/living-income-calculations/"} {p_end}


