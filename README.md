# Appliance Scheduler Important Notes and Instructions


## Survey Results

- **SurveyData_Raw.xlsx** contains all the appliance schedule surveyed data where all the names of the respondents were redacted for confidentiality. 
- **SurveyData_Filtered.xlsx** contains the filtered data. The raw survey data was filtered to check for validity of respondents answers. This is to ensure that there are no contradictions in all parameters in the respondents answers. Slight modifications were done for typo errors and invalid (unclear, incomplete, contradicting, etc.) survey answers were not included to the filtered survey results. 
- **SurveyResults_ProcessedPercentages.xlsx** contains the required percentage distributuions for all the included appliance parameters in the project. This was created based from the filtered survey data. 

## City Generation

- **probability_data.m** contains the same data in **SurveyResults_ProcessedPercentages.xlsx** but the data were stored as matrices in a single MATLAB file (.m). 
- **CityGeneration.m** uses **probability_data.m** as input to convert the survey data results to generate a city with 14,061 households. The  generated output households are stored into a matrix with 'H#' as the array name (# corresponds to the number/ID of the specific consumer). Note that the households are saved into MATLAB files in sets of 700. If other household number is desired to be generated, the _output identifier_ snippet (line 11-22) should be modified accordingly.
- **appmatrix.m** is a function that supports the **CityGeneration.m**. This function is responsible in creating the appliance matrix of each household user. 

## City Simulation

- **CityWideWithHASS.m** contains the BPSO-based HASS scheduler that takes the generated household userinputs from **CityGeneration.m** as inputs, and simulate the city in consideration of HASS. This outputs the average electricity cost, peak demand, PAR, average user satisfaction, invalid schedules, etc. of the simulated city. The simulation is also limited to 700 households per run. 
- **objFunc1.m** contains the objective function that is used by **CityWideWithHASS.m**. This uses the appliance, PV, ESS, & EV data as inputs and outputs the fitness (objective function value) of a specific household schedule. 
- **BatteryCode.m** contains the battery/ESS function that is used by **CityWideWithHASS.m**. This outputs the battery charge/discharge schedule stored in a 1x24 array. Positive if charging, negative if discharging.
- **EVCode.m** contains the EV function that is used by **CityWideWithHASS.m**. This outputs the EV charge schedule where the charging operation is optimized to flat the household load curve. 
- **tou_rates24.m** contains the TOU pricing scheme data used in this project (MERALCO POP rates)
- **CityWithoutHASS.m** is also a city wide simulation but the BPSO-based HASS scheduler is not included in the simulation. This simulation pertains to the "original schedule" or the 100% satisfaction schedule (all appliances and EV are scheduled to operate as early as possible in the user desired time frame). The uses the same functions and inputs as **CityWideWithHASS.m** and also provides the same output parameters. (the main difference is the presence of HASS)
- **userinputs folder** contains all the required user inputs for the simulation. **userinput<1-20>.m** are the outputs of **CityGeneration.m** that is used in the city-wide simulation, while **userinput_testcases.m** contains the most probable schedule per household type that are used in the sensitivity & flexibility analysis. 

## Simulation Results
