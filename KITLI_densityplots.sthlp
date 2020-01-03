{smcl}
{* *! version 0  2jan2020}{...}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Density (kernel smoothened) plots, optionally by groups.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: KITLI_densityplots}
{varlist} {ifin}, options

{synoptset 30 tabbed}{...}
{synopthdr:optional}
{synoptline}

{syntab: Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}

{syntab: Graph hard edges}

{synopt :{opth hard_min:(text)}} string indicating the hard lower edges (per group) {p_end}
{synopt :{opth hard_max:(text)}} string indicating the hard upper edges (per group) {p_end}

{syntab: Graph labels}

{synopt :{opth ytitle:(text)}} Text for y axis. Default "Proportion of households (%)" {p_end}

{syntab: Graph colors}
{synopt :{opth colors:(text)}} String with colors for the graph. Default "ebblue%30 | blue%30 | green%30 | orange%30" {p_end}

{syntab: Graph exporting}

{synopt :{cmd:nosave}} does not save the generated graph (default behavior is to save) {p_end}
{synopt :{opth subfolder:(text)}} (relative) subfolder to save the graph. Default is the current folder {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd: KITLI_densityplots} produces density ({help kdensity:kernel smoothened}) plots as fractions about the distribution of underlying variables for the indication of the household income, optionally.  

{pstd}
It allows to force hard edges to the smoothened distribution.

{pstd} It produces graphs similar to what can be seen at:
{browse "https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf"}
{browse "https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf"}


{title:Options}

{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, density charts will have one curve per group. {p_end}


{dlgtab: Graph hard edges}
{pmore}
{opth hard_min:(text)} string indicating the hard lower edges (per group). It follows the format "number | number | number" {p_end}

{pmore}
{opth hard_max:(text)} string indicating the hard upper edges (per group). It follows the format "number | number | number". {p_end}


{dlgtab: Graph labels}
{pmore}
{opth ytitle:(text)} Text for y axis. If not specified,  {it:Proportion of households(%)} is shown. {p_end}


{dlgtab: Graph colors}
{pmore}{it:For more information see {help colorstyle}}

{pmore}
{opth colors:(text)} Colors for the curves. Multiple colors need to be separated by a "|".  Default "ebblue%30 | blue%30 | green%30 | orange%30".  {p_end}


{dlgtab: Graph exporting}

{pmore}
{cmd:nosave} does not save the generated graph (default behavior is to save). Graph name will start with the variable name followed by "_density_plot". {p_end}

{pmore}
{opth subfolder:(text)} (relative) subfolder to save the graph. Default is the current folder. Please make sure name is correct includes "/" as separator if needed. Folder will be created if necessary. {p_end}


{title:Examples}

{phang}Setup

{phang}{cmd:. use LI_example_data.dta, replace}{p_end}

{phang}Density plots, by group

{phang}{cmd:. KITLI_densityplots prod_total_last_kg_ha revenue_usdha_2018 li_inputs_usdha_2018 li_hired_usdha_2018 total_income_2018 total_hh_income_2018, grouping_var(grouping)}{p_end}

{phang}Density plots with hard edges for groups 1 and 2

{phang}{cmd:. KITLI_densityplots cocoa_land_used_morethan5_ha, grouping_var(grouping) nosave hard_min( "0 | 4 | ") hard_max(" 4 | 1000 | ")}{p_end}

{title:Citation}
{phang}
{cmd:KITLI_densityplots} is not an official Stata command. It is a free contribution to the research community, like a paper.
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


