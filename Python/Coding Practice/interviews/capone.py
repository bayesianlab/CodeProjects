#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd
from pandasql import sqldf

flights = pd.read_csv("Flights.csv")
airports = pd.read_csv("Airport_Codes.csv")
tickets = pd.read_csv("Tickets.csv")

airports = airports.query("ISO_COUNTRY == 'US' ")
big_airports = airports.query("TYPE == 'medium_airport' | TYPE == 'large_airport'")

big_airports = big_airports.drop(["ELEVATION_FT","CONTINENT","ISO_COUNTRY","MUNICIPALITY"], 
                  axis=1)


big_airports = big_airports.loc[-pd.isna(big_airports['IATA_CODE']),:]
flights['rowid'] = flights.index
T1 = flights[['ORIGIN_AIRPORT_ID', 'ORIGIN', 'ORIGIN_CITY_NAME', 'DEP_DELAY',
              'ARR_DELAY','CANCELLED', 'AIR_TIME', 'DISTANCE', 'OCCUPANCY_RATE',
              'rowid']].merge(big_airports,left_on='ORIGIN', right_on='IATA_CODE')
T1 = T1.rename(columns={'TYPE': 'ORIGIN_TYPE', 'COORDINATES':'ORIGIN_COORD'})
T2 = flights[['DEST_AIRPORT_ID', 'DESTINATION','DEST_CITY_NAME',
              'rowid']].merge(big_airports[['TYPE', 'COORDINATES', 'IATA_CODE']], 
                              left_on='DESTINATION',right_on='IATA_CODE')
T2 = T2.rename(columns={'TYPE':'DEST_TYPE', 'COORDINATES':'DEST_COORD'})
flights = T1.merge(T2[['rowid', 'DEST_TYPE', 'DEST_COORD', 'DESTINATION', 'DEST_CITY_NAME']], left_on='rowid', right_on='rowid')



cols = ['rowid','ORIGIN', 'DESTINATION', 'ORIGIN_TYPE', 'DEST_TYPE', 'ORIGIN_CITY_NAME', 'DEST_CITY_NAME', 
 'ORIGIN_COORD', 'DEST_COORD', 'DEP_DELAY', 'ARR_DELAY', 'AIR_TIME', 'DISTANCE', 'OCCUPANCY_RATE',
 'CANCELLED']

flights = flights.loc[flights['CANCELLED'] != 1,]
flights =flights.drop('CANCELLED', axis=1)

tickets['ROUNDTRIP'].astype('bool')
tickets.loc[tickets['ROUNDTRIP'] == 1,:]
tickets = tickets[['ORIGIN', 'DESTINATION', 'ITIN_FARE']]

tickets['rowid'] = tickets.index
T1 = tickets.merge(big_airports[['TYPE', 'COORDINATES', 'IATA_CODE']], 
                left_on='ORIGIN',right_on='IATA_CODE')
T1 = T1.rename(columns={'TYPE': 'ORIGIN_TYPE', 'COORDINATES':'ORIGIN_COORD'})
T2 = tickets.merge(big_airports[['TYPE', 'COORDINATES', 'IATA_CODE']], 
                left_on='DESTINATION',right_on='IATA_CODE')
T2 = T2.rename(columns={'TYPE':'DEST_TYPE', 'COORDINATES':'DEST_COORD'})
tickets = T1[['rowid', 'ORIGIN', 'ORIGIN_TYPE', 'ORIGIN_COORD']].merge(T2[['rowid', 'DESTINATION', 'DEST_TYPE', 'DEST_COORD', 'ITIN_FARE']],  
                   left_on='rowid', right_on='rowid')

tickets = tickets[['ORIGIN', 'DESTINATION', 'ITIN_FARE']]

tickets['ITIN_FARE'] = tickets['ITIN_FARE'].apply(pd.to_numeric, errors='coerce')
tickets = tickets.loc[-pd.isna(tickets['ITIN_FARE']),:]

query = """
Select ORIGIN, DESTINATION, AVG(ITIN_FARE), COUNT() from tickets GROUP BY ORIGIN, DESTINATION;
"""
tickets = sqldf(query)