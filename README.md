# TIMEVP: Time Series Visualization and Processing Toolkit
a.k.a. Time is Very imPortant toolkit

by Tian Linger Xu

STEPS to use this toolkit:
1. Download a clone of this toolkit to your own labtop. You can click the green button `Clone or download` to download a ZIP file. Or, if you use Git Bash, simply type in:
```
git clone https://github.com/lingerxu/timevp.git
```
2. Open Matlab and set your working path to the folder containing the downloaded toolkit.
3. Create a data folder and put all csv files in the data directory.

    The csv files contain time series type data. This toolkit supports two types of time series data structure:

    **stream**: a stream of time series data. The csv file should contain a N by 2 matrix. N is the length of the time series. Two columns are [timestamp category_value].

        e.g.
                   344.7000   32.0000
                   344.8000   34.0000
                   344.9000   34.0000
                   345.0000   34.0000
                   345.1000   34.0000
                   345.2000   34.0000
                   345.3000   34.0000
                   345.4000   32.0000
                   345.5000   32.0000
                   345.6000   32.0000

    **event**: time series events with start time and end time. The csv file should contain a N by 3 matrix. N is the total number of events. Three columns are [onset offset category_value].

        e.g.
                    69.0280   69.9450     1.0000
                    72.5080   73.8050     4.0000
                    75.4820   87.1540     1.0000
                    91.3940  104.1530     4.0000
                    108.3860  111.1130    4.0000
                    103.1310  121.1620    1.0000
                    122.7510  123.5740    1.0000                     
                    150.0210  153.8760    4.0000
                    154.0310  155.9760    1.0000

    The data files should be stored in the following structure:

    - [subject ID]
        - [variable1].csv
        - [variable2].csv
        - [variable3].csv
        ...
        - [variableN].csv

    We provided example data under [yulab_data](yulab_data/)

  4. Open *timevp_config_dataset_info.m* to set the data directory to your own data directory and sampling rate of your time series data. If you data was collected at 10 HZ (10 data points per second), then your sampling rate is 0.1. In our example dataset, the time series data were collected at 30 HZ, so the sampling rate is roughly 0.034.

    e.g.

        sample_rate = 0.034;
        dir_dataset = 'yulab_data';


  5. Open each demo file and start analyzing your data! Each demo file is independent from each other.

Please see this file for an in-depth tutorial provided at ICIS 2018.
