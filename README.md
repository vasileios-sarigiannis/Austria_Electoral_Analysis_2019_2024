# Austria Voter Transitions | 2019–2024 European Parliament Elections

## Project Overview

This R project uses Austria as a case study to estimate potential voter transitions between European Parliament political groups from the 2019 to the 2024 European Parliament elections.

The analysis uses electoral data from Austrian national political parties, classified according to their European Parliament political-group affiliations in each election year. It examines estimated voter transitions, voter retention, abstention, and regional changes in electoral support.

Voter transitions are estimated using the Voter Transition Rates (VTR) methodology developed by Ioannis Andreadis and Theodore Chadjipadelis (2009), with supporting R code provided by the Laboratory of Applied Political Research at Aristotle University of Thessaloniki.

## Project Files

| File | Description |
|---|---|
| `Austria_Electoral_Analysis.pdf` | Full research report, including theoretical framework, methodology, findings, and conclusions. |
| `Austria_Electoral_Analysis_RMarkdown.pdf` | Rendered computational analysis with R code, tables, visualizations, and regional maps. |
| `Austria_Electoral_Analysis.Rmd` | R Markdown source document. |
| `analysis.R` | Main R analysis script. |
| `VTR.R` | Supporting voter-transition estimation functions. |
| `austria_2019.csv` | Austrian European Parliament election data for 2019. |
| `austria_2024.csv` | Austrian European Parliament election data for 2024. |
| `austria_map.geojson` | Austrian NUTS 2 geographical boundaries. |
| `Austria_Voter_Transitions.Rproj` | RStudio project file. |
| `Austria_Electoral_Analysis_README.pdf` | Detailed project instructions and reproducibility guide. |

## How to Run the Analysis

1. Download the repository and keep all project files in the same folder.
2. Open `Austria_Voter_Transitions.Rproj` in RStudio.
3. Open `analysis.R`.
4. Install any missing R packages: `tidyverse`, `scales`, `ggalluvial`, `sf`, and `rmarkdown`.
5. Run `analysis.R` from top to bottom.

For detailed instructions on how to reproduce the analysis, please refer to the [Austria_Electoral_Analysis_README.pdf](Austria_Electoral_Analysis_README.pdf).

## Methodological Notes

The voter-transition estimates are derived from aggregate regional election data. They are ecological estimates, not direct observations of individual voting behavior.

FPÖ is associated with Identity and Democracy (ID) in 2019 and Patriots for Europe (PfE) in 2024. Therefore, the estimated ID → PfE transition reflects continuity among FPÖ voters across a change in European political-group affiliation.

## Explore the Research

- [Full Research Report](Austria_Electoral_Analysis.pdf)
- [R Markdown Analysis and Visualizations](Austria_Electoral_Analysis_RMarkdown.pdf)
- [R Markdown Source](Austria_Electoral_Analysis.Rmd)
- [Detailed Project Instructions — README PDF](Austria_Electoral_Analysis_README.pdf)

## Methodological Reference

Andreadis, I., & Chadjipadelis, T. (2009). *A Method for the Estimation of Voter Transition Rates*. Journal of Elections, Public Opinion and Parties.
