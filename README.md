# 'kit_livingincome': LIVING INCOME CALCULATIONS AND OUTPUTS: stata package to produce tables and charts of the Gap to the Living Income Benchmark
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

## Developed by [KIT](http://www.kit.nl) and [COSA](http://thecosa.org/)
[Last update 07/08/2020] 

`kit_livingincome` provides stata ado-files to produce tables and charts of the Gap to the Living Income Benchmark.
 
It produces graphs similar to what can be seen at:

https://www.kit.nl/wp-content/uploads/2019/01/Analysis-of-the-income.pdf

https://docs.wixstatic.com/ugd/0c5ab3_93560a9b816d40c3a28daaa686e972a5.pdf

A detailed Guidance Manual can be found at:

https://www.living-income.com/papersandreports

or directly at:

https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2F0c5ab38c-aabb-4d3d-84e9-056ccebab450.usrfiles.com%2Fugd%2F0c5ab3_74a43f3647724bc58caf4daaa570482b.pdf&data=02%7C01%7Cm.tyszler%40kit.nl%7Cf199ee7ce9bd423b54ff08d838827f5f%7C99193bd4318d47c6a89624e15f7a7e1b%7C1%7C1%7C637321480450701968&sdata=HkxU0DQng8cl3PW%2B6oL7NK%2BuHGcQQzhtpKXT5UMAhZE%3D&reserved=0


### Authors

Marcelo Tyszler. KIT Royal Tropical Institute, Netherlands. m.tyszler@kit.nl

Carlos de los Rios. COSA. cd@thecosa.org

#### Other Contributors

Elena Serfilippi. KIT Royal Tropical Institute, Netherlands.

Esther Smits. KIT Royal Tropical Institute, Netherlands.

Suchitra Yegna Narayan. Laudes Foundation


### Requirements

* Stata version 14 

## Installing `kit_livingincome`
To install directly from the [SSC archive](https://econpapers.repec.org/software/bocbocode/S458819.htm), type:
```
ssc install kit_livingincome
```


To install the latest development version directly from Github using stata `github` package, type: 
```
net install github, from("https://haghish.github.io/github/") 
github install mtyszler/KIT_LivingIncome
```

To install using stata `net` command, type:
```
net from https://raw.githubusercontent.com/mtyszler/kit_livingincome/master/
net install kit_livingincome
```

### Alternative installation procedures

If you have problems using the commands above, there are 2 possible work-arounds, using the [this zip file](kit_livingincome.zip)

#### Manually installing into your ado library

If using the default settings from STATA:

Windows users: Create a folder called `C:\ado\personal\`, if not existent, and extract the contents of the zip file here.

Mac OS X users: Create a folder called `~/ado/personal`, if not existent, and extract the contents of the zip file here.

To verify your local setting type `sysdir` or `adopath` in STATA.

For more details on how configure local folders type `help adopath` in STATA.

#### Manually installing into your local folder

If none of the options above worked, a final work-around is to extract the contents of the zip file to a local folder. 

The commands will work only when this is the active STATA working directory.


### Verifying the installation:

To verify you have the latest version of the package successfully installed type:
```
help kitli_gap2bm
```

or

```
help kitli_compare2bm
```

And take notice of the version and date at the top. The latest version is _v1.4, 07aug2020_

## Citation

Please cite the package as follows:

> Tyszler, et al. (2020). Living Income Calculations Toolbox. KIT ROYAL TROPICAL 
INSTITUTE and COSA. Available at: https://github.com/mtyszler/KIT_LivingIncome/

## License
[![License: CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/80x15.png)](https://creativecommons.org/licenses/by-sa/4.0/)

This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.


