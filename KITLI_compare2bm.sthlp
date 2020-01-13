{smcl}
{* *! version 0  2jan2020}{...}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Density (kernel smoothened) plots about the total household income with the goal of comparing to the benchmark value, optionally by groups.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: KITLI_compare2bm}
{it:li_benchmark} {ifin}, arguments

{synoptset 30 tabbed}{...}
{synopthdr:mandatory arguments}
{synoptline}

{synopt :{opth bm_achieved:(varname)}} {varname} of an indicator variable on whether a household achieved the benchmark {p_end}
{synopt :{opth total_hh_income:(varname)}} {varname} of total household income {p_end}


{synopthdr:optional arguments}
{synoptline}

{syntab: Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}

{syntab: Graph options}

{synopt :{opth ytitle:(text)}} Text for y axis. Default "Proportion of households (%)" {p_end}
{synopt :{opth spacing:(real)}} Value for spacing between the boxes of the combined graph of all groups. Default to 0.02 {p_end}
{synopt :{opth colors:(text)}} String with colors for the graph. Default "ebblue%30 | blue%30 | green%30 | orange%30" {p_end}

{syntab: Graph exporting}

{synopt :{cmd:nosave}} does not save the generated graph (default behavior is to save) {p_end}
{synopt :{opth subfolder:(text)}} (relative) subfolder to save the graph. Default is the current folder {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd: KITLI_compare2bm} produces density ({help kdensity:kernel smoothened}) plots as fractions about the distribution of total household income with the goal of comparing to the benchmark value. If a grouping variable is used, it creates a single graph per group and a combined graph.

{pstd} It produces graphs similar to what can be seen at:
{browse "https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf"}
{browse "https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf"}


{title:Arguments}

{dlgtab:Main}

{pmore}
{cmd:li_benchmark} {varname} which containts the living income benchmark value per observation.
{p_end}

{dlgtab:Mandatory}

{pmore}
{opth bm_achieved:(varname)} {varname} of an indicator variable on whether a household achieved the benchmark. It should have a value of 1 in case of achievement and 0 otherwise {p_end}

{pmore}
{opth total_hh_income:(varname)} {varname} of total household income, including the main income source. 


{pmore}{it:{cmd:li_benchmark} and {opth total_hh_income:(varname)} need to be in the same currency and unit (e.g., USD per household).}
{p_end}


{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, density charts will have one curve per group. {p_end}


{dlgtab: Graph options}

{pmore}
{opth ytitle:(text)} Text for y axis. If not specified,  {it:Proportion of households(%)} is shown. {p_end}

{pmore}
{opth spacing:(real)} Value for spacing between the boxes of the combined graph of all groups. Only relevant if grouping_var:(varname) is provided. Default to 0.02 {p_end}

{pmore}
{opth colors:(text)} Colors for the curves. Multiple colors need to be separated by a "|".  Default "ebblue%30 | blue%30 | green%30 | orange%30".  {p_end}

{pmore}{it:For more information see {help colorstyle}}


{dlgtab: Graph exporting}

{pmore}
{cmd:nosave} does not save the generated graph (default behavior is to save). Graph name will start with the total_hh_income:(varname) variable name followed by "_living_income_benchmark" and the group label, if applicable. {p_end}

{pmore}
{opth subfolder:(text)} (relative) subfolder to save the graph. Default is the current folder. Please make sure name is correct includes "/" as separator if needed. Folder will be created if necessary. {p_end}


{title:Examples}

{phang}Setup

{phang}{cmd:. use LI_example_data.dta, replace}{p_end}

{phang}Comparison plots for all

{phang}{cmd:. KITLI_compare2bm benchmark_cluster, bm_achieved(li_benchmark_achieved) total_hh_income(total_hh_income_2018)  }{p_end}

{phang}Comparison plots, by group

{phang}{cmd:. KITLI_compare2bm benchmark_cluster, bm_achieved(li_benchmark_achieved) total_hh_income(total_hh_income_2018)  grouping_var(grouping) }{p_end}


{title:Citation}
{phang}
{cmd:KITLI_compare2bm} is not an official Stata command. It is a free contribution to the research community, like a paper.
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


