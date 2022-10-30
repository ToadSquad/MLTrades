# MLTrades
Objective of this project is to use Machine learning to decipher whether or not to take a trade in the Forex Market
# The Data
Gen one of this project will simply collect price data as a float and than whether the market moves a specified range from entry. TP and SL. if it hits TP result is 1, if it hits SL result is -1 else it is 0

![alt text](https://i.imgur.com/HPpz5uk.png)

Data is collected via Metrader with MQL5 script, with this script we can collect various symbols with a large data range. 

# Data Proccessing
Scikit is used to run a decision tree classifier on the data, this is since we are only trying to predict the labels 1,-1,0 which correspond to Buy, Sell, Nuetral. 

Current Bar data is gathered with Yfinance and run against the saved data and the ML model. this will output a result, in order to get a percentage we will mix the data and run it severeal times against the model to output a percent.

if the percentage is above 60% for 1 we will Buy, if it is above 60% for sell we will Sell otherwise we do not trade.

# Trade Tracking

Trade tracking is done simply with a trade class and dill to store the list of trade objects through code executions.

# Back Testing

120 Day Period

![alt text](https://i.imgur.com/9gh24nq.png)
