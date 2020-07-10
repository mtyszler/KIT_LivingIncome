{smcl}
{* *! version 1.1  03jul2020}{...}
{it: v1.1, 03jul2020}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Tables, density (kernel smoothened) and bar plots about 
the total household income with the goal of comparing to the benchmark value, optionally by groups.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: kitli_compare2bm}
{it:li_benchmark} {ifin}, arguments

{synoptset 30 tabbed}{...}
{synopthdr:mandatory arguments}
{synoptline}

{synopt :{opth hh_income:(varname)}} {varname} of total household income {p_end}


{synopthdr:optional arguments}
{synoptline}

{syntab: Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}

{syntab: Labels}

{synopt :{opt label_benchmark:(text)}} Text for benchmark name. Default "Living Income Benchmark" {p_end}

{syntab: Graph options}

{synopt :{opt ytitle:(text)}} Text for y axis. Default "Proportion of households (%)" {p_end}
{synopt :{opt spacing:(number)}} Value for spacing between the boxes of the combined graph of all groups. Defaults to 0.02 {p_end}
{synopt :{opt placement:(text)}} Placement of the boxes of the indicating the share of those below the benchmark. Defaults to {it:right}. {p_end}
{synopt :{opt step_size:(integer)}} Value for step size in the x-axis. Defaults to a value calculated internally {p_end}
{synopt :{opt colors:(text)}} String with colors for the graph. Default "ebblue%30 | blue%30 | green%30 | orange%30" {p_end}

{syntab: Graph exporting}

{synopt :{cmd:show_distribution_graph}} shows a distribution graph comparing to the benchmark  {p_end}
{synopt :{cmd:show_detailed_graph}} shows detailed distribution graphs 
(separated graphs per group if grouping variables is provided) 
comparing to the benchmark, including mean and median values  {p_end}
{synopt :{cmd:show_bar_graph}} shows a bar graph of the share below the benchmark  {p_end}
{synopt :{opt save_graph_as:(text)}} main stub of filename to be saved. Graphs will be saved as png format {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd: kitli_compare2bm} produces tables, bar charts and density ({help kdensity:kernel smoothened}) plots as fractions about the distribution of 
total household income with the goal of comparing to the benchmark value. If a grouping variable is used, it creates, optionally, 
a detailed graph per group and a combined graph.

{pstd} It produces graphs similar to what can be seen at:

{pstd} {browse "https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf"}

{pstd} {browse "https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf"}

{pstd} This function includes options to customize key elements of the graphs. 
Please notice, however, that all graphs can be further edited using Stata's {help graph_editor} capabilities. 



{title:Arguments}

{dlgtab:Main}

{pmore}
{cmd:li_benchmark} {varname} which containts the living income benchmark value per observation.
{p_end}

{dlgtab:Mandatory}

{pmore}
{opth hh_income:(varname)} {varname} of total household income, including the main income source. 


{pmore}{it:{cmd:li_benchmark} and {opth hh_income:(varname)} need to be in the same currency and unit (e.g., USD per household).}
{p_end}


{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, density charts will have one curve per group. {p_end}

{dlgtab: Labels}
{pmore}
{opth label_benchmark:(text)} Text for benchmark name. If not specified,  {it:Living Income Benchmark} is shown. {p_end}

{dlgtab: Graph options}

{pmore}
{opt ytitle:(text)} Text for y axis. If not specified,  {it:Proportion of households(%)} is shown. {p_end}

{pmore}
{opt spacing:(number)} Value for spacing between the boxes of the combined graph of all groups. Only relevant if grouping_var:(varname) is provided. Defaults to 0.02 {p_end}

{pmore}
{opt placement:(text)} Placement of the boxes/text in the graphs. Defaults to {it:right}, i.e., the boxes are placed to the right of the benchmark line. 
Typically, one might want to use {it:left} as an alternative, if the text gets cut-off to the right. 
See {help compassdirstyle} for more valid options.  {p_end}

{pmore}
{opt step_size:(integer)} Value for step size in the x-axis. Bin size for the density calculation is set as half of this value. 
If ommitted, it is calculated internally. 
Because the internal calculation might not suit all ranges of values, 
the user can choose to override its value {p_end}

{pmore}
{opt colors:(text)} Colors for the curves. Multiple colors need to be separated by a "|".  Default "ebblue%30 | blue%30 | green%30 | orange%30".  {p_end}

{pmore}{it:For more information see {help colorstyle}}


{dlgtab: Graph exporting}

{pmore}
{cmd:show_distribution_graph} shows a distribution graph (with groups overlayed, if provided), 
comparing to the benchmark {p_end}

{pmore}
{cmd:show_detailed_graph} shows detailed distribution graphs, i.e. distribution, benchmark, mean and median values
, as separated graphs per group if groups are provided. {p_end}

{pmore}
{cmd:show_bar_graph} shows a bar graph with the share of those below the benchmark, per group if groups are provided. {p_end}

{pmore}
{opt save_graph_as:(text)} Main stub for the filename used for saving the graphs. Graphs are in png format (appended to the filename). 
Distribution graphs have the word {it:distribution} appended,
detailed graphs have the word {it: detailed} appended,
and bar graphs have the word {it: bar} appended. 
Finally,  group graphs have the group label appended to the file name. {p_end}



{title:Examples}

{phang}Setup

{phang}{cmd:. use https://raw.githubusercontent.com/mtyszler/KIT_LivingIncome/master/kitli_exampledata.dta}
({stata "use https://raw.githubusercontent.com/mtyszler/KIT_LivingIncome/master/kitli_exampledata.dta":{it:click to run}}) {p_end}

{phang}Comparison plots for all

{phang}{cmd:. kitli_compare2bm benchmark, hh_income(total_hh_income_2018) show_graph }
({stata "kitli_compare2bm benchmark, hh_income(total_hh_income_2018) show_graph":{it:click to run}}) {p_end}

{phang}Comparison plots for all, saving

{phang}{cmd:. kitli_compare2bm benchmark, hh_income(total_hh_income_2018) show_graph save_graph_as(example_density)} 
({stata "kitli_compare2bm benchmark, hh_income(total_hh_income_2018) show_graph save_graph_as(example_density)":{it:click to run}}) {p_end}

{phang}Comparison plots, by group

{phang}{cmd:. kitli_compare2bm benchmark, hh_income(total_hh_income_2018)  grouping_var(grouping) show_detailed_graph}
({stata "kitli_compare2bm benchmark, hh_income(total_hh_income_2018)  grouping_var(grouping) show_detailed_graph":{it:click to run}}) {p_end}


{title:Citation}
{phang}
{cmd:kitli_compare2bm} is not an official Stata command. It is a free contribution to the research community, like a paper.
Please cite it as such:{p_end}

{phang}
Tyszler, et al. (2020). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: {browse "https://github.com/mtyszler/KIT_LivingIncome/"} 
{p_end}

{phang}
If you have requests or suggestions, please do so at our repository:  {browse "https://github.com/mtyszler/KIT_LivingIncome/"} {p_end}


{title:Authors}
{phang} Marcelo Tyszler {bf:{it: (Package maintainer)}}. KIT Royal Tropical Institute, Netherlands. {browse "mailto:m.tyszler@kit.nl":m.tyszler@kit.nl} {p_end}

{phang} Carlos de los Rios. COSA.  {browse "mailto:cd@thecosa.org":cd@thecosa.org}{p_end}


{title:References}
{phang}
Github repository:  {browse "https://github.com/mtyszler/KIT_LivingIncome/"} {p_end}


