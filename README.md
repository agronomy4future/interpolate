<!-- README.md is generated from README.Rmd. Please edit that file -->

# interpolate

<!-- badges: start -->
<!-- badges: end -->

The goal of the Interpolate package is to predict intermediate data points using interpolation.

□ Code summary: https://github.com/agronomy4future/r_code/blob/main/An_easy_way_to_use_interpolation_code_to_predict_in_between_data_points.ipynb

□ Code explained: https://agronomy4future.com/archives/23834

## Installation

You can install the development version of interpolate like so:

Before installing, please download Rtools (https://cran.r-project.org/bin/windows/Rtools)

``` r
if(!require(remotes)) install.packages("remotes")
if (!requireNamespace("normtools", quietly = TRUE)) {
    remotes::install_github("agronomy4future/interpolate", force= TRUE)
}
library(remotes)
library(interpolate)
```

## Example

This is a basic code to interpolate data

``` r
# interpolate by grouping
result= interpolate(df, x="days", y="ch", group_vars= c("crop","reps"))
```

## Let’s practice with actual dataset

``` r
# to uplaod data
if(!require(readr)) install.packages("readr")
library(readr)
github="https://raw.githubusercontent.com/agronomy4future/raw_data_practice/refs/heads/main/chlorophyll_content_2024.csv"
df= data.frame(read_csv(url(github), show_col_types=FALSE))

print(head(df,5))
print(tail(df,5))
  season    crop reps days   ch
1   2024 Sorghum    1   65 65.8
2   2024 Sorghum    2   65 63.0
3   2024 Sorghum    3   65 62.7
4   2024 Sorghum    4   65 61.4
5   2024 Sorghum    1   75 57.3
.
.
.
52   2024 Soybean    4  115 35.3
53   2024 Soybean    1  125  9.2
54   2024 Soybean    2  125  0.0
55   2024 Soybean    3  125  7.2
56   2024 Soybean    4  125  6.1

# to interpolate by grouping
result= interpolate(df, x="days", y="ch", group_vars= c("crop","reps"))

print(head(result,5))
print(tail(result,5))
  crop     reps season  days    ch category
1 Sorghum     1   2024    65  65.8        0
2 Sorghum     1     NA    66  65.0        1
3 Sorghum     1     NA    67  64.1        1
4 Sorghum     1     NA    68  63.2        1
5 Sorghum     1     NA    69  62.4        1
.
  crop     reps season  days    ch category
1 Soybean     4     NA   121 17.8         1
2 Soybean     4     NA   122 14.9         1
3 Soybean     4     NA   123 11.9         1
4 Soybean     4     NA   124  9.02        1
5 Soybean     4   2024   125  6.1         0
.
.
.

# A new column, 'category', is created, where 0 represents actual data and 1 represents interpolated data.
```
