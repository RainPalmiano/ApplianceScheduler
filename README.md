# Appliance Scheduler Important Notes and Instructions


## Survey Results

-**SurveyData_Raw.xlsx** contains all the appliance schedule surveyed data where all the names of the respondents were redacted for confidentiality. 

-**SurveyData_Filtered.xlsx** contains the filtered data. The raw survey data was filtered to check for validity of respondents answers. This is to ensure that there are no contradictions in all parameters in the respondents answers. Slight modifications were done for typo errors and invalid (unclear, incomplete, contradicting, etc.) survey answers were not included to the filtered survey results. 

-**SurveyResults_ProcessedPercentages.xlsx** contains the required percentage distributuions for all the included appliance parameters in the project. This was created based from the filtered survey data. 

## City Generation

-**probability_data.m** contains the same data in **SurveyResults_ProcessedPercentages.xlsx** but the data were stored as matrices in a single MATLAB file (.m). 

-**CityGeneration.m** uses **probability_data.m** as input to convert the survey data results to generate a city with 14,061 households. This is done through Monte Carlo Analysis. This code can use any household appliance schedule survey data with the same format as **probability_data.m**, to generate any number of households. The  generated output households are stored into a matrix with 'H#' as the array name (# corresponds to the number/ID of the specific consumer). Note that the households are saved into MATLAB files in sets of 700. For cases that the houshold generated is not a multiple of 700, the remainder are stored in the last MATLAB file. 

-

## City Simulation


## City Simulation Results
