{smcl}
{* *! version 0  13jan2020}{...}

{title:Title}

{phang}
{bf:(KIT) Living Income Tools} {hline 2} Farm level profit model for a single main crop in relation to the living Income Benchmark.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: KITLI_farmlevelmodel}
{it:li_benchmark} {ifin}, arguments

{synoptset 30 tabbed}{...}
{synopthdr:(mandatory) model elements}
{synoptline}

{synopt :{opth total_main_income:(varname)}} {varname} of total income from main source {p_end}
{synopt :{opth total_hh_income:(varname)}} {varname} of total household income {p_end}
{synopt :{opth total_production:(varname)}} {varname} of total household production in one year {p_end}
{synopt :{opth productive_farm:(varname)}} {varname} of total area of household productive farm {p_end}
{synopt :{opth price:(varname)}} {varname} of price per unit of weight of the production {p_end}
{synopt :{opth revenue_total:(varname)}} {varname} of total value of production {p_end}
{synopt :{opth input_costs:(varname)}} {varname} of total input costs per household per year {p_end}
{synopt :{opth hiredlabour_cost:(varname)}} {varname} of total hired labour costs per household per year {p_end}
{synopt :{opth all_costs:(varname)}} {varname} of all costs per household per year {p_end}
{synopt :{opth hh_size:(varname)}} {varname} of household size {p_end}

{syntab: (mandatory) file exporting}

{synopt :{opth filename:(text)}} (full) name of the excel file to be exported {p_end}
{synopt :{opth wsheet:(text)}} worksheet name within the excel file to receive the exports {p_end}


{synopthdr:optional arguments}
{synoptline}

{syntab: Grouping}

{synopt :{opth grouping_var:(varname)}} grouping variable {p_end}

{syntab: Calculation}

{synopt :{opth statistic:(text)}} statistic to be calculated. Default "mean" {p_end}

{syntab: Model labels}

{synopt :{opth label_currency:(text)}} Text for currency name. Default "USD" {p_end}
{synopt :{opth label_weight:(text)}} Text for weight unit. Default "kg" {p_end}
{synopt :{opth label_land:(text)}} Text for land unit. Default "ha" {p_end}

{synoptline}


{title:Description}

{pstd}
{cmd: KITLI_farmlevelmodel} produces a farm level profit model for a single main source of income in relation to the living Income Benchmark.

{pstd} It produces tables similar to what can be seen at:
{browse "https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf"}
{browse "https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf"}

{pstd} The model takes as input the living income benchmark value and elements for profit calculation. 

{pstd} It exports a formatted excel table with the inputs and additional calculations (yield, share of main income and gap to the living income benchmark). Optionally, it includes the breakdown per group.

{pstd} The default behavior is to report averages, but other percentiles are also possible. 

{pstd} {cmd: KITLI_farmlevelmodel} uses {help summarize} and {help putexcel}. 

{pstd} {cmd: Please be aware the excel file will have its contents overwritten}. Therefore the file needs to be closed. If the file does not exist it will be created. If it does exist, the contents will be overwritten, but not cleared. 

{pstd} It is therefore adviced to clear the contents of the target worksheet to avoid confusion. 

{title:Arguments}

{dlgtab:Main}

{pmore}
{cmd:li_benchmark} {varname} which containts the living income benchmark value per observation.
{p_end}

{dlgtab:Mandatory model elements}

{pmore}
{opth total_main_income:(varname)} {varname} of total income from main source, for example main crop sales. The table assumes there is one main income source. 

{pmore}
{opth total_hh_income:(varname)} {varname} of total household income, including the main income source. 

{pmore}
{opth total_production:(varname)} {varname} of total household production in one year. 

{pmore}
{opth productive_farm:(varname)} {varname} of total area of household productive farm. 

{pmore}
{opth price:(varname)} {varname} of price per unit of weight of the production. 

{pmore}
{opth revenue_total:(varname)} {varname} of total value of production. 

{pmore}
{opth input_costs:(varname)} {varname} of total input costs per household per year. 

{pmore}
{opth hiredlabour_cost:(varname)} {varname} of total hired labour costs per household per year. 

{pmore}
{opth all_costs:(varname)} {varname} of all production costs per household per year, including inputs and hired labour. 

{pmore}
{opth hh_size:(varname)} {varname} of household size. This is not actually used by any calculation but it is a very important refernce value and therefore in required to be included. {p_end}

{pmore} {it:Currency of {cmd:li_benchmark} and other monetary valued variables need to be the same (e.g., USD).}

{pmore} {it:Weight unit of {cmd:total_production} and other related valued variables need to be the same (e.g., kg).}

{pmore} {it:Land unit of {cmd:productive_farm} and other related valued variables need to be the same (e.g., ha).}
{p_end}


{dlgtab: File exporting}

{pmore}
{opth filename:(text)} (full) name of the excel file to be exported, including existing subfolders if desire. If you use subfolder, please use "/" as separator. {cmd: Please be aware the excel file will have it contents overwritten}. {p_end}

{pmore}{opth wsheet:(text)} worksheet name within the excel file to receive the exports. It will be created if not existent. If it exists, content will be overwritten, but not cleared elsewhere. {p_end}


{dlgtab:Grouping}
{pmore}
{opth grouping_var:(varname)} grouping variable. If specified, the table will have one column per group. {p_end}


{dlgtab:Calculation}
{pmore}
{opth statistic:(text)} statistic to be calculated. One of the return values of {help summarize}, such as {it: p50}, i.e., median. Default is "mean" {p_end}


{dlgtab: Model labels}
{pmore}
{opth label_currency:(text)} Text for currency name. If not specified,  {it:USD} is shown. {p_end}

{pmore}
{opth label_weight:(text)} Text for weight unit. If not specified, {it:kg} is shown. {p_end}

{pmore}
{opth label_land:(text)} Text for land unit. If not specified, {it:ha}  is shown.  {p_end}



{title:Examples}

{phang}{it:Setup}

{phang}{cmd:. use LI_example_data.dta, replace}{p_end}

{phang}{it:Farm level model, by group:}

{phang}KITLI_farmlevelmodel benchmark_cluster, total_main_income(total_income_2018) total_hh_income(total_hh_income_2018) total_production(prod_total_last_kg) productive_farm(cocoa_land_used_morethan5_ha) price(price_usdkg_2018) revenue_total(revenue_total_2018) input_costs(li_inputs_usdhh_2018) hiredlabour_cost(li_hired_usdhh_2018) all_costs(li_costs_usdhh_2018) hh_size(hhmem_number) filename("Farm Level model.xlsx") wsheet("Compare avg farms") grouping_var(grouping) {p_end}

{phang}{it:Farm level model, by group, with medians}

{phang}KITLI_farmlevelmodel benchmark_cluster, total_main_income(total_income_2018) total_hh_income(total_hh_income_2018) total_production(prod_total_last_kg) productive_farm(cocoa_land_used_morethan5_ha) price(price_usdkg_2018) revenue_total(revenue_total_2018) input_costs(li_inputs_usdhh_2018) hiredlabour_cost(li_hired_usdhh_2018) all_costs(li_costs_usdhh_2018) hh_size(hhmem_number) filename("Farm Level model.xlsx") wsheet("Compare avg farms") grouping_var(grouping) statistic(p50) {p_end}


{title:Citation}
{phang}
{cmd:KITLI_farmlevelmodel} is not an official Stata command. It is a free contribution to the research community, like a paper.
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


