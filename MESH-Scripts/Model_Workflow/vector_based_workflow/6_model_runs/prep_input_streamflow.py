import pandas as pd

title           = 'Saint Mary Milk'
num_gauges      = 3
stationNumbers  = ['05AE027','11AA031','11AA025']
time_step       = 24
start_year      = 2010
start_day       = 1         # (1-365)
start_hour      = 0         # (0-24)
domain_name     = 'SaintMaryMilk'


df1 = pd.read_csv('../workflow_data/domain_SaintMaryMilk/daily_05AE027.csv', skiprows=1)
df2 = pd.read_csv('../workflow_data/domain_SaintMaryMilk/daily_11AA031.csv', skiprows=1)
df3 = pd.read_csv('../workflow_data/domain_SaintMaryMilk/daily_11AA025.csv', skiprows=1)


df1['DD'] = df1['DD'].astype(str)
df2['DD'] = df2['DD'].astype(str)
df3['DD'] = df3['DD'].astype(str)
df1['YEAR'] = df1['YEAR'].astype(str)
df2['YEAR'] = df2['YEAR'].astype(str)
df3['YEAR'] = df3['YEAR'].astype(str)
df1['YEAR-DAY'] = df1[['YEAR','DD']].apply('-'.join, axis = 1)
df2['YEAR-DAY'] = df2[['YEAR','DD']].apply('-'.join, axis = 1)
df3['YEAR-DAY'] = df3[['YEAR','DD']].apply('-'.join, axis = 1)

out_df = pd.merge(pd.merge(df1,df2,on='YEAR-DAY'),df3,on='YEAR-DAY')

import math
x = []
for i in out_df.iterrows():
    if math.isnan(i[1][11]):
        x.append(0)
    else:
        x.append(i[1][11])
out_df['Value_y'] = x

x = []
for i in out_df.iterrows():
    if math.isnan(i[1][17]):
        x.append(0)
    else:
        x.append(i[1][17])
out_df['Value'] = x

for i in out_df.iterrows():
    year = i[1][2]
    if int(year) < start_year:
       out_df = out_df.drop(i[0])
print('Start year selected...')
print('Combining values ...')
combined = pd.DataFrame()
out_df['Value_x'] = out_df['Value_x'].astype(str)
out_df['Value_y'] = out_df['Value_y'].astype(str)
out_df['Value'] = out_df['Value'].astype(str)
combined['Value'] = out_df[['Value_x','Value_y','Value']].apply(" ".join, axis =1)
combined['YEAR-DAY'] = out_df['YEAR-DAY']

combined.to_csv('./smm_streamflow.csv')