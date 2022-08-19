# Install packages 
install.packages("readxl")
install.packages("RNetCDF")

# Load libraries
library(readxl)
library(RNetCDF)

# Load data
data <- read_excel("01_dummy_data_depth_profile.xlsx")
print(data)

# Creating NetCDF file
nc <- create.nc("dummy_data_netcdf_file.nc")
print(nc)

# Define dimensions
dim.def.nc(nc, "depth", nrow(data))

# Create coordinate variable
var.def.nc(nc,"Depth","NC_INT", "depth")
print.nc(nc)
var.def.nc(nc,"Temperature","NC_DOUBLE","depth")
var.def.nc(nc,"PracticalSalinity","NC_DOUBLE","depth")

var.put.nc(nc,"Depth",data$Depth)
var.put.nc(nc,"Temperature",data$Temperature)
var.put.nc(nc,"PracticalSalinity",data$PracticalSalinity)
print.nc(nc)

att.put.nc(nc,"Depth","long_name","NC_CHAR","Sample depth in meters below the sea level")
att.put.nc(nc,"Depth","standard_name","NC_CHAR","depth")
att.put.nc(nc,"Depth","units","NC_CHAR","m")
att.put.nc(nc,"Depth","coverage_content_type","NC_CHAR","coordinate")

att.put.nc(nc,"Temperature","long_name","NC_CHAR","Sea water temperature in degrees C measured by a CTD")
att.put.nc(nc,"Temperature","standard_name","NC_CHAR","sea_water_temperature")
att.put.nc(nc,"Temperature","units","NC_CHAR","degreeC")
att.put.nc(nc,"Temperature","coverage_content_type","NC_CHAR","physicalMeasurement")
att.put.nc(nc,"Temperature", "_FillValue", "NC_DOUBLE", -99999.9)
var.get.nc(nc,"Temperature")
att.get.nc(nc,"Temperature","_FillValue")

att.put.nc(nc,"PracticalSalinity","long_name","NC_CHAR","Sea water practical salinity in 1e-3 measured by a CTD")
att.put.nc(nc,"PracticalSalinity","standard_name","NC_CHAR","sea_water_practical_salinity")
att.put.nc(nc,"PracticalSalinity","units","NC_CHAR","1e-3")
att.put.nc(nc,"PracticalSalinity","coverage_content_type","NC_CHAR","physicalMeasurement")

print.nc(nc)

global_attributes <- read_excel("01_dummy_data_depth_profile.xlsx", sheet="Metadata")
print(global_attributes)

for (i in 1:nrow(global_attributes)) {
  row <- global_attributes[i,]
  if (row$Format == "NC_DOUBLE") {
    att.put.nc(nc,"NC_GLOBAL",row$AttributeName,"NC_DOUBLE",as.double(row$Content))
  }
  else {
    att.put.nc(nc,"NC_GLOBAL",row$AttributeName,"NC_CHAR",row$Content)
  }
}

dtnow <- format(Sys.time(), tz="UTC", "%FT%R:%SZ")
att.put.nc(nc,"NC_GLOBAL","date_created","NC_CHAR",dtnow)
att.put.nc(nc,"NC_GLOBAL","history","NC_CHAR",paste("File created using RNetCDF by Luke Marsden at ",dtnow))
print.nc(nc)

close.nc(nc)

ncin <- open.nc("dummy_data_netcdf_file.nc")
print.nc(ncin)

