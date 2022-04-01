#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 30 09:30:21 2022

@author: lukem
"""

# Import modules
import xarray as xr
import pandas as pd
from datetime import datetime as dt

# Load data
data = pd.read_excel('dummy_data.xlsx', sheet_name = 'Data')
global_attributes = pd.read_excel('dummy_data.xlsx', sheet_name = 'Global_Attributes')

# Write data to xarray object
xrds = xr.Dataset(
    coords = dict(
        depth = list(data['Depth'])
    ),
    data_vars = dict(
        practical_salinity = (['depth'], data['PracticalSalinity']),
        temperature = (['depth'], data['Temperature'])
        )
    )

# Assign global attributes
for idx, row in global_attributes.iterrows():
    xrds.attrs[row['Attribute']] = row['Value'] 

dtnow = dt.now().strftime("%Y-%m-%dT%H:%M:%SZ")
xrds.attrs['date_created'] = dtnow
xrds.attrs['history'] = f'File create at {dtnow} using xarray in Python'

# Assign variable attributes

xrds['depth'].attrs = {
    'standard_name': 'depth',
    'long_name': 'depth below sea surface',
    'units': 'meters',
    'coverage_content_type': 'coordinate',
    'positive': 'down'
    }

xrds['practical_salinity'].attrs = {
    'standard_name': 'sea_water_practical_salinity',
    'long_name': 'Practical salinity of sea water',
    'units': '1e-3',
    'coverage_content_type': 'physicalMeasurement'
    }

xrds['temperature'].attrs = {
    'standard_name': 'sea_water_temperature',
    'long_name': 'Temperature of sea water',
    'units': 'degree_C',
    'coverage_content_type': 'physicalMeasurement'
    }

# Specifiy encoding
myencoding = {
    'depth': {
        'dtype': 'int32',
        '_FillValue': None # Coordinate variables should not have fill values.
        },
    'temperature': {
        'dtype': 'float32',
        '_FillValue': 1e30,
        'zlib': False
        }, 
    'practical_salinity': {
        'dtype': 'float32',
        '_FillValue': 1e30,
        'zlib': False
        }
    }

xrds.to_netcdf('dummy_depth_profile.nc',encoding=myencoding)