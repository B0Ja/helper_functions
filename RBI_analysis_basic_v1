#To be moved to the RBI Project directory

"""
This function has not been tested for all the RBI data on 
the page. The structure of all the pages are different.

This has been tested and worked on in the Population,
Urban population and Rural Population pages.

Generally, should work with single table pages.
"""

def rbi_chart(data):
    
    """Get the data from RBI and plot the heatmap and delta map"""
    
    #Import modules needed to run
    import numpy as np
    import pandas as pd
    import matplotlib.pyplot as plt
    import seaborn as sns; sns.set()
    from rbidata import social_demographic
    
    #Import Dict set
    x = social_demographic
    
    #Read data
    df = pd.read_html(x[data][1],  skiprows=1, header=0, na_values=np.nan )[1]
    
    #Transformation of data
    df.rename(columns = {'States/Union Territories':'states'}, inplace = True)

    ##Setting Index and removing the Table notes
    df.set_index('states', inplace = True)
    df = df[: -2]

    ##Setting Arunachal Pradesh as 0. 
    df.loc[['Arunachal Pradesh'], ['1951']] = 0 

    ##Changing the Data Types to Int
    for i in df.columns:
        df[i] = df[i].astype(int)

    ##Sorting data by 2011
    df.sort_values(by=['2011'], ascending =False, inplace =True)
    
    df = df[df['2011']>500]
    
    df = df[:15]

    #Make a sample delta dataframe
    df_delta = df.diff(axis=1)
    
    
    #Plot the charts using seaborn    
    fig, ax = plt.subplots(1, 2, figsize = (6,6), constrained_layout=False)
    #cax = fig.add_axes([0.27, 0.8, 0.5, 0.05])

    ax1 = sns.heatmap(data = df, cmap = 'gist_rainbow', xticklabels=True, yticklabels=True, linewidth=0.5, annot=False, cbar = False, square=True,  ax=ax[0])
    ax2 = sns.heatmap(data = df_delta, cmap = 'gist_rainbow', xticklabels=True, yticklabels=False, linewidth=0.5, annot=False, cbar = False, square=True, ax=ax[1])
    
    
    ax1.set(title=x[data][0])
    ax1.set(ylabel='States of India')

    ax2.set(title = x[data][0] +' Increase')
    #ax2.set(xticklabels=[])
    ax2.set(ylabel=None)

    #plt.subplots_adjust(wspace=0.01, hspace=0.03)
    plt.tight_layout()
    
rbi_chart('sex_ratio')
