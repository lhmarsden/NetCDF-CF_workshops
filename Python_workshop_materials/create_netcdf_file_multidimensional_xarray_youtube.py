#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  6 08:42:49 2023

@author: lukem
"""


import xarray as xr # For creating a NetCDF dataset
import pandas as pd # For reading in data (CSV, xlsx etc) to a dataframe
from datetime import datetime as dt # Handling dates and times
import numpy as np # Good for working with multidimensional arrays and mathematical functions

df = pd.read_excel('multidimensional_sea_water_temperature_variables.xlsx', sheet_name='Data')

latitude = sorted(list(set(df['Latitude'])))
longitude = sorted(list(set(df['Longitude'])))
time = sorted(list(set(df['Day'])))


sea_surface_skin_temperature = np.array(df['Sea water temperature (degC)']).reshape(5,2,3)

xrds = xr.Dataset(
    coords = dict(
        longitude = longitude, # These coordinate names are compliant with CF conventions (all lower case)
        latitude = latitude, #
        time = time #
    ),
    data_vars = dict(
        sea_surface_skin_temperature = (["time", "latitude", "longitude"], sea_surface_skin_temperature)
    )
)

xrds['time'].attrs['standard_name'] = 'time'
xrds['time'].attrs['long_name'] = 'time'
xrds['time'].attrs['units'] = 'days since 2020-07-10T12:00:00Z'
xrds['time'].attrs['coverage_content_type'] = 'coordinate'

xrds['latitude'].attrs = {
'standard_name': 'latitude',
'long_name':'decimal latitude in degrees north',
'units': 'degrees_north',
'coverage_content_type': 'coordinate'
}

xrds['longitude'].attrs = {
'standard_name': 'longitude',
'long_name':'decimal longitude in degrees east',
'units': 'degrees_east',
'coverage_content_type': 'coordinate'
}

# xrds['depth'].attrs = {
# 'standard_name': 'depth',
# 'long_name':'depth below sea level',
# 'units': 'meters',
# 'coverage_content_type': 'coordinate',
# 'positive': 'down'
# }

# xrds['pressure'].attrs = {
# 'standard_name': 'sea_water_pressure',
# 'long_name':'sea_water_pressure',
# 'units': 'Pa',
# 'coverage_content_type': 'coordinate'
# }

# xrds['altitude'].attrs = {
# 'standard_name': 'altitude',
# 'long_name':'altitude above mean sea level',
# 'units': 'meters',
# 'coverage_content_type': 'coordinate',
# 'positive': 'up'
# }

xrds['sea_surface_skin_temperature'] += 273.15 # Converting from degrees celsius to kelvin

xrds['sea_surface_skin_temperature'].attrs = {
'standard_name':'sea_surface_skin_temperature',
'long_name':'Temperature of the sea water directly below the surface',
'units': 'K',
'coverage_content_type': 'physicalMeasurement'
}


xrds.attrs['title'] = 'my title'

global_attributes = pd.read_excel('multidimensional_sea_water_temperature_global_attributes.xlsx', index_col=0)
global_attributes_transposed = global_attributes.transpose()
global_attributes_dic = global_attributes_transposed.to_dict('records')[0]
xrds.attrs=global_attributes_dic
xrds.attrs['date_created'] = dt.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
xrds.attrs['history'] = f'File create at {dt.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")} using xarray in Python'

myencoding = {
            'time': {
                'dtype': 'int32',
                '_FillValue': None # Coordinate variables should not have fill values.
                },
            'latitude': {
                'dtype': 'float32',
                '_FillValue': None # Coordinate variables should not have fill values.
                },
            'longitude': {
                'dtype': 'float32',
                '_FillValue': None # Coordinate variables should not have fill values.
                },
            'sea_surface_skin_temperature': {
                '_FillValue': -999,
                'zlib': False
                }
            }
        
xrds.to_netcdf('multidimensional_sea_water_temperature.nc',encoding=myencoding)
