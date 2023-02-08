import pandas as pd
from matplotlib import pyplot as plt

streamflow = pd.read_csv('/project/6008034/calbano/SaintMary-Milk_Hydrathon/MESH-Scripts/Model_Workflow/vector_based_workflow/6_model_runs/SaintMaryMilk_RTE_2/results/MESH_output_streamflow.csv')
cols = streamflow.columns
cols2 = []
for i in cols:
    cols2.append(i.strip())
streamflow.columns = cols2
streamflow['Date'] = streamflow['YEAR'].astype(str) +'/'+streamflow['JDAY'].astype(str)
streamflow['Date'] = pd.to_datetime(streamflow['Date'],format='%Y/%j')

plt.plot(streamflow['Date'],streamflow['QOMEAS1'],'r',label='Measured Streamflow (m3/s)')
plt.plot(streamflow['Date'],streamflow['QOSIM1'],'b',label='Simlated Streamflow (m3/s)')
plt.legend()
plt.title('05AE029')
plt.savefig('./hydrograph.png',dpi=300)
plt.close()

plt.plot(streamflow['Date'],streamflow['QOMEAS2'],'r',label='Measured Streamflow (m3/s)')
plt.plot(streamflow['Date'],streamflow['QOSIM2'],'b',label='Simulated Streamflow (m3/s)')
plt.legend()
plt.title('11AA031')
plt.savefig('./hydrograph2.png',dpi=300)
