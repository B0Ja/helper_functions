import pandas as pd
import datetime

x = pd.date_range(start='6/15/2020', end='8/12/2020')

saturdays = [day.date() for day in x if day.weekday() == 5]
fridays = [day.date() for day in x if day.weekday() == 4]

"""
for i in saturdays:
    print('Sat: {}'.format(i))
    
for i in fridays:
    print('Fri: {}'.format(i))
""" 
   
for i in fridays:
    for j in saturdays:
        print('Fri: {}'.format(i))
        print('Sat: {}'.format(i))
        print('\n')
        
        
