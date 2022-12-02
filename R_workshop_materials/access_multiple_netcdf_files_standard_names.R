library(RNetCDF) # work with NetCDF files
library(tidyverse) # work with dataframes

extract_global_attribute_from_netcdf <- function(nc,global_attribute) {
  tryCatch(
    {
      result <- att.get.nc(nc,"NC_GLOBAL",global_attribute)
      return(result)
    },
    error = function(cond) {
      message(paste(global_attribute,"attribute not found"))
      message("Here is the original error message")
      message(cond)
    }
  )
}

folder <- "/home/lukem/Documents/Access_Multiple_NetCDF_Files/NetCDF_Files"
files <- list.files(folder, full.names=TRUE)

standard_names <- c("depth", "mass_concentration_of_chlorophyll_a_in_sea_water")

global_attributes <- c(
  'geospatial_lat_min',
  'geospatial_lon_min',
  'time_coverage_start',
  'time_coverage_end',
  'stationName',
  'cruiseName')

headers <- c(global_attributes,standard_names)

df <- data.frame(matrix(ncol=length(headers), nrow=0))
colnames(df) <- headers

for (file in files) {
  nc <- open.nc(file)
  
  num_depths <- 0 
  
  nvars <- as.integer(file.inq.nc(nc)['nvars'])
  for (var_idx in 0:(nvars-1)) {
    natts <- as.integer(var.inq.nc(nc,var_idx)['natts'])
    for (att_idx in 0:(natts-1)) {
      att_name <- att.inq.nc(nc,var_idx,att_idx)['name']
      if (att_name == "standard_name") {
        sname <- att.get.nc(nc,var_idx,att_idx)
        if (sname == "depth") {
          depths <- var.get.nc(nc,var_idx)
          num_depths <- length(depths)
        }
      }
    }
  }
  
  newdf <- data.frame(matrix(ncol=length(headers), nrow=num_depths))
  colnames(newdf) <- headers
  
  for (global_attribute in global_attributes) {
    newdf[global_attribute] <- extract_global_attribute_from_netcdf(nc,global_attribute)
  }
  
  for (var_idx in 0:(nvars-1)) {
    natts <- as.integer(var.inq.nc(nc,var_idx)['natts'])
    for (att_idx in 0:(natts-1)) {
      att_name <- att.inq.nc(nc,var_idx,att_idx)['name']
      if (att_name == "standard_name") {
        sname <- att.get.nc(nc,var_idx,att_idx)
        if (sname %in% standard_names) {
          newdf[sname] <- var.get.nc(nc,var_idx)
        }
      }
    }
  }
  
  df <- merge(df,newdf,all=TRUE)
}

library(writexl)
write_xlsx(df, "/home/lukem/Documents/Access_Multiple_NetCDF_Files/Chlorophyll_data_standard_names.xlsx")

