# shinyBI moved

Project is no longer active but still usable. I've made similar shiny app, it is faster and focused on hierarchical / dimensional data. It is available in [dwtools](https://github.com/jangorecki/dwtools) package.

# shinyBI: proof of concept - up to [Jul 1, 2014](https://github.com/jangorecki/shinyBI/commit/7b2d72be49771ccece3bcef22c09d7a31583c568).

shinyBI is R package which delivers simple Business Intelligence platform as `shiny` application.

User can load own dataset, perform pivot process utilizing the performance of `data.table`, plot a chart on pivot results utilizing interactivity of `rCharts`.

**Current version**: 0.3 ([NEWS](https://github.com/jangorecki/shinyBI/blob/master/NEWS))

## Installation

```R
library(devtools)
install_github("rCharts", "ramnathv") # not yet on CRAN
install_github("data.table", "Rdatatable") # v1.9.3 required, not yet on CRAN
install_github("shinyBI", "jangorecki")
```

## Usage

```R
library(shinyBI)
shinyBI()
```

## Documentation

 - [About](https://github.com/jangorecki/shinyBI/blob/master/inst/shinyBI/about.md)
 - [Loading data](https://github.com/jangorecki/shinyBI/blob/master/inst/shinyBI/source.md)
 - [Pivot](https://github.com/jangorecki/shinyBI/blob/master/inst/shinyBI/pivot.md)
 - [Plot](https://github.com/jangorecki/shinyBI/blob/master/inst/shinyBI/plot.md)

## License

[GPL-3](https://github.com/jangorecki/shinyBI/blob/master/LICENSE.md)

## Contact

email: `j.gorecki@wit.edu.pl`
