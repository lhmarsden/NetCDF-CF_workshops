#install.packages("RNetCDF")
library(RNetCDF) # working with NetCDF files
#install.packages("tidyverse")
library(tidyverse) # merging dataframes

# Function to pull global attributes from a NetCDF object, and post an error message if fails but continue
extract_global_attribute_from_nc <- function(nc, global_attribute) {
  tryCatch(
    {
      result <- att.get.nc(nc,"NC_GLOBAL",global_attribute)
      return(result)
    },
    error = function(cond) {
      message(paste(global_attribute,' attribute not found in NetCDF object'))
      message("Here's the original error message:")
      message(cond)
    },
    warning=function(cond) {
      message(paste("Warning message for attribute ", global_attribute))
      message("Here's the original warning message:")
      message(cond)
    },
  )
}

# Function to pull variables from a NetCDF object, and post an error message if fails but continue
extract_variable_from_nc <- function(nc, variable) {
  tryCatch(
    {
      result <- var.get.nc(nc,variable)
      return(result)
    },
    error = function(cond) {
      message(paste(variable,' variable not found in NetCDF object'))
      message("Here's the original error message:")
      message(cond)
    },
    warning=function(cond) {
      message(paste("Warning message for variable ", variable))
      message("Here's the original warning message:")
      message(cond)
    },
  )
}

# Vector of variables that I am going to extract from the NetCDF file
# The name should match the variable names in the NetCDF file
variables <- c(
  "DEPTH",
  "CHLOROPHYLL_A_TOTAL",
  "PHAEOPIGMENTS_TOTAL",
  "FILTERED_VOL_TOTAL",
  "EVENTID_TOTAL",
  "CHLOROPHYLL_A_10um",
  "PHAEOPIGMENTS_10um",
  "FILTERED_VOL_10um",
  "EVENTID_10um"
)

# Vector of global attributes that I am going to extract from the NetCDF file
# The name should match the global attribute name in the NetCDF file
global_attributes <- c(
  "cruiseNumber",
  "stationName",
  "geospatial_lat_min",
  "geospatial_lat_max",
  "geospatial_lon_min",
  "geospatial_lon_max",
  "time_coverage_start",
  "time_coverage_end"
)

# One column for each global attribute and variable listed above
columns <- c(global_attributes,variables)
df <- data.frame(matrix(ncol = length(columns), nrow = 0))
colnames(df) <- columns

# Where my NetCDF files are stored
path <- "/home/lukem/Documents/Training/shortvideos/NetCDF/R/Extract_multiple_files"
# Creating a list of subdirectories within the above filepath
# [-1] to remove directory itself from list
folders <- list.dirs(path)[-1]

for (folder in folders) {

  files <- list.files(folder, full.names = TRUE)
  
  for (file in files) {
    
    nc <- open.nc(file)
    
    nrows = length(var.get.nc(nc,"DEPTH"))
    
    newdf <- data.frame(matrix(ncol = 0, nrow = nrows))
    
    for (global_attribute in global_attributes) {
      newdf[global_attribute] <- extract_global_attribute_from_nc(nc, global_attribute)
    }
    
    for (variable in variables) {
      newdf[variable] <- extract_variable_from_nc(nc, variable)
    }
    
    df <- merge(df,newdf,all=TRUE)
    
  }
}

#library(writexl)
#write_xlsx(df,"/home/lukem/Documents/r_chla_all.xlsx")

