#' Interpolate Missing Values by Group
#'
#' This function performs linear interpolation on a dataset, grouping by specified variables.
#' It ensures that missing values within each group are estimated based on existing values.
#'
#' @param data A data frame containing the variables to interpolate.
#' @param x A string representing the column name of the independent variable (e.g., time or position).
#' @param y A string representing the column name of the dependent variable to be interpolated.
#' @param group_vars A character vector of column names specifying the grouping variables.
#'
#' @return A data frame with interpolated values. The output includes an additional column `category`,
#' where 0 represents original values and 1 represents interpolated values.
#'
#' @export
#'
#' @examples
#'if(!require(remotes)) install.packages("remotes")
#'if (!requireNamespace("interpolate", quietly = TRUE)) {
#'  remotes::install_github("agronomy4future/interpolate", force= TRUE)
#'}
#'library(remotes)
#'library(interpolate)

#' data= data.frame(
#'   group= rep(c("A","B"), each= 5),
#'   time= c(1, 2, 3, 5, 6, 1, 3, 4, 5, 6),
#'   value= c(10, 15, NA, 30, 35, 5, 10, NA, 25, 30)
#' )
#'
#' result= interpolate(data, x="time", y="value", group_vars= "group")
#' print(result)
#'
interpolate= function(data, x, y, group_vars) {

  if (require("dplyr") == F) install.packages("dplyr")
  library(dplyr)

  data[[x]]= as.numeric(data[[x]])
  data[[y]]= as.numeric(data[[y]])

  # Store the exact original column order from original data
  original_order= names(data)

  # Group by specified variables and interpolate separately for each group
  interpolated_data= data %>%
    group_by(across(all_of(group_vars))) %>%
    group_modify(~ {
      if (nrow(.x) < 2) return(.x)  # Skip groups with too few points to interpolate

      full_range= seq(min(.x[[x]], na.rm= TRUE), max(.x[[x]], na.rm= TRUE))
      interp_result= approx(.x[[x]], .x[[y]], xout= full_range, rule= 2)  # rule=2 extends if needed

      if (length(interp_result$y)== 0) return(.x)  # If interpolation failed, return original data

      # Create interpolated dataset
      interp_df= data.frame(x= interp_result$x, y= interp_result$y)
      colnames(interp_df)= c(x, y)  # Ensure column names match input

      # Assign category: 0 for actual data, 1 for interpolated
      interp_df$category= ifelse(interp_df[[x]] %in% .x[[x]], 0, 1)

      # Merge with original data to retain additional columns
      merged_df= merge(interp_df, .x, by= x, all.x = TRUE)

      # Identify and remove any duplicated y column (e.g., ch.y)
      y_column= grep(paste0("^", y, "\\.y$"), names(merged_df), value = TRUE)
      if (length(y_column) > 0) {
        merged_df= merged_df %>% select(-all_of(y_column))
      }

      # Fix column names if 'ch.x' was created during merging
      y_x_column= grep(paste0("^", y, "\\.x$"), names(merged_df), value = TRUE)
      if (length(y_x_column) > 0) {
        colnames(merged_df)[colnames(merged_df)== y_x_column]= y
      }

      # Ensure column order matches the original order of the original data
      final_order= c(original_order, "category")
      final_order= intersect(final_order, names(merged_df))  # Keep only existing columns in correct order
      merged_df= merged_df[, final_order]

      return(merged_df)
    }) %>%
    ungroup()

  return(interpolated_data)
}
