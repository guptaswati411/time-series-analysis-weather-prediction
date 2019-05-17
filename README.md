# Weather Prediction using Time Series Anaylsis

## Introduction
The aim of the project is to analyze weather data to predict temperatures. The data includes daily temperature and wind speed data from Jan 1, 2014 to April 24, 2019 of Portland. The data is provided by NOAA. It was collected and filtered using Google Cloud BigQuery. We compare predictions made by univariate and multivariate time series models on the data. We study the effects of wind speed on temperature predictions and the accuracy of the predictions.

## Approach
We start by plotting the temperature and wind speed data for exploratory analysis. The following figures show the plots obtained. We can see a clear annual seasonality in temperature data. Similar seasonality can also be seen in the wind data.

![Temp-plot](/images/Tplots.png)
![Wind-plot](/images/Wplots.png)

To account for seasonality, we difference the data at a lag of 365 days. The new values are plotted again along with the ACF and PACF values

![Diff-data](/images/Differenced_data.png)
![Diff-ACF](/images/ACF_Diffrenced_data.png)
![Diff-PACF](/images/PACF_differenced_data.png)

We can see that we now have a two stationary time series. We divide the data into training and test. All data up to 2018 are taken to be training and everything from 2019 is test data.

We start by trying to fit a univariate model to the temperature data. We fit an ARIMA model where the values of $p$, $d$, $q$ are calculated based on the AIC of the models. We see that the values of 12, 1, 8 respectively give the minimum AIC. The model summary is included in the code file. We do a residual analysis to ensure there is no correlation between them. The plots of residual analysis is as shown.

![Res](/images/residual.png)

The residuals follow a normal distribution and the ACF plot indicated no correlation between them. We now use this model to make predictions on the test data. The predictions are shown in the following graph

![ARIMA](/images/Arima.png)

We see that while the first few values were captured close to the real values, the later values tend to converge to zero.
While some of the variations in the data are captured by the model, the model fails to capture the extent of the variations observed in the data.

We now try to fit a VAR model to the data We again use AIC to find the optimum p value for the VAR model. The optimum value of p is 8. We now fit a VAR model with p = 8. The summary of the model is included in the code file. We again make predictions using the model and the plot is as shown below

![VAR](/images/VAR.png)

We again see that while the initial few predictions are close to the observed values, the predictions quickly converge to 0

## Conclusion

Based on our results, we see that while the first few predictions were close, the later predictions were not very accurate. The models fail to predict values much further into the future.\\

We also do not see a significant improvement in predictions after including wind speed in the model. This may be because temperature predictions require more parameters than just wind speed.

## References
1. Brockwell,  Peter  J.  and  Davis,  Richard  A.  (1991),  Introduction  to  Time  Series and Forecasting, Springer-Verlag, New York
2. Shumway, Robert H., Stoffer, David S. (2006), Time Series Analysis and Its Applications (with R examples), Springer-Verlag, New York
3. Climate Data Online, NOAA, Department of Commerce 
