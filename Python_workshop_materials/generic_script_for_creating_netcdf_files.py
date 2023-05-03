#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May  3 11:14:23 2023

@author: lukem
"""

import xarray as xr
import numpy as np

# Create some coordinate arrays
depth = np.array([0,10,20,30])

latitude = np.array([31.2112, 31.7005, 31.8157, 32.8313])
longitude = np.array([21.4152, 21.5532, 21.7142, 21.9102])

# Creating an array of timestamps
start = np.datetime64('2022-01-01T00:00:00')
end = start + np.timedelta64(24, 'h')
timestamps = np.arange(start, end, np.timedelta64(1, 'h'))

# In CF-NetCDF, time is stored in e.g. seconds since 2022-01-01T00:00:00Z, hours since 2022-01-01T00:00:00Z
seconds_since_start = (timestamps - start).astype('int')
hours_since_start = (timestamps - start).astype('timedelta64[h]').astype('int')

# Add them to an xarray object

xrds = xr.Dataset(
    coords = {
        'depth': depth,
        'latitude': latitude,
        'longitude': longitude,
        'time': seconds_since_start
        }
    )

# Now let's add some data variables.

xrds['chlorophyll'] = ("depth", [21.5, 18.5, 17.6, 16.8]) # This is 1D

wind_speed = np.random.randint(0, 10, size=(4, 4))    # Creating a 2D array

xrds['wind_speed'] = (["latitude", "longitude"], wind_speed) # This is 2D

temperature = np.random.randint(20,30, size=(4,4,4))

xrds['temperature'] = (["latitude", "longitude", "depth"], temperature) # This is 3D

# Variable attributes

xrds['depth'].attrs = {
    'standard_name': 'depth',
    'positive': 'down'
    }

xrds['time'].attrs['units'] = 'seconds since 2022-01-01T00:00:00Z'

# Global attributes

xrds.attrs = {
    'title': 'my title',
    'creator_name': 'Luke Marsden'
    }

print(xrds)