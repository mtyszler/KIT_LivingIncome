{smcl}
{* *! version 0  13jan2020}{...}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Inputation of values, optionally by group.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: KITLI_inputations}
{varlist} {ifin}, options

{synoptset 30 tabbed}{...}
{synopthdr:optional}
{synoptline}

{syntab: Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}

{syntab: Processing}

{synopt : {opt generate(prefix)}}generate new variables for each variable in {varlist} using {it:prefix}{p_end}
{synopt : {opt replace}}replace variables in {varlist} {p_end}

{pstd}* {it:Either {opt generate(prefix)} or {opt replace} is required.}

{synoptline}


{title:Description}

{pstd}
{cmd: KITLI_inputations} replaces missing values by the median of the subset, optionally within group. The purpose is to fill in gaps in the data to maximize usability of data. 

{title:Options}

{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, inputation will be done within group. {p_end}


{dlgtab:Processing}
{pstd}
Either {opt generate()} or {opt replace} must be specified.  {p_end}

{pmore}
{opth generate(prefix)} generates new variables for each variable in {varlist} using {it:prefix}. If generate is set, a complete copy of the variable will be create for the full dataset and the inputation will be applied to the subset defined. For example, variable {it:prefix_var} will be created as a copy of {it:var} and then inputation will be processed. {cmd: Please make sure the prefix is valid and not an existing name.}{p_end}

{pmore}
{cmd:replace} replaces the content of variables in {varlist} {p_end}



{title:Examples}

{phang}Setup

{phang}{cmd:. use LI_example_data.dta, replace}{p_end}

{phang}Inputations, by group, generating new variables 

{phang}{cmd:. KITLI_inputations gfertilizer_total_cost_usdha lfertilizer_total_cost_usdha herbicide_total_cost_usdha pesticide_total_cost_usdha fungicide_total_cost_usdha, grouping_var(grouping) generate(li_)}{p_end}

{phang} Inputations for a subset, by group

{phang}{cmd:. KITLI_inputations li_gfertilizer_total_cost_usdha if  gfertilizer_yn == 1, grouping_var(grouping) generate(li_)}{p_end}

{title:Citation}
{phang}
{cmd:KITLI_inputations} is not an official Stata command. It is a free contribution to the research community, like a paper.
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


