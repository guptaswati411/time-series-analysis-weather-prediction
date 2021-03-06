rm(list=ls())
library(forecast)
library(vars)
data = read.csv("datanew.csv",header=T)

temp.ts = ts(as.numeric(data$temperature),start=c(2014),frequency=365.25)
wind.ts = ts(as.numeric(data$wind_speed),start=c(2014),frequency=365.25)
data.ts = ts.union(temp.ts,wind.ts)
par(mfrow=c(2,2))
plot(temp.ts, type="l",main="Temperature",ylab="Temperature")
hist(temp.ts, main="Distribution of values",xlab="Temperature")
acf(temp.ts,main="ACF plot for Temperature")  
pacf(temp.ts,main="PACF plot for Temperature")
par(mfrow=c(2,2))
plot(wind.ts, type="l",main="Wind",ylab="Wind")
hist(wind.ts, main="Distribution of values",xlab="Wind")
acf(wind.ts, main="ACF plot for Wind")  
pacf(wind.ts, main="PACF plot for Wind")

# Difference data
dtemp=diff(temp.ts, lag=365)
dwind=diff(wind.ts,lag = 365)
data.ts=ts.union(dtemp,dwind)
plot(data.ts, type="l",main="")
acf(data.ts)
pacf(data.ts)

# Train test split
data=data.ts
n = nrow(data)
data.train=data[1:(n-114),]
data.test=data[(n-113):n,]
temp_train=ts(dtemp[1:(n-114)],start=c(2014),frequency=365.25)
wind_train=ts(dwind[1:(n-114)],start=c(2014),frequency=365.25)
temp_test=ts(dtemp[(n-113):n],start=c(2019),frequency=365.25)
wind_test=ts(dwind[(n-113):n],start=c(2019),frequency=365.25)

# Univariate ARIMA model

final.aic = Inf
final.order = c(0,0,0)
for (p in 11:13) for (d in 0:2) for (q in 7:9) {
  #print(c(p, d, q))
  current.aic = AIC(arima(temp_train, order=c(p, d, q), method="ML"))
  if (current.aic < final.aic) {
    final.aic = current.aic
    final.order = c(p, d, q)
    
  }
}
print(final.order)
# final order: 12  1  8

model.arima = arima(temp_train, order=final.order, method="ML")
summary(model.arima)

# Residual analysis

par(mfrow=c(2,2))
plot(resid(model.arima), ylab='Residuals',type='o',main="Residual Plot")
abline(h=0)
acf(resid(model.arima),main="ACF: Residuals")
hist(resid(model.arima),xlab='Residuals',main='Histogram: Residuals')
qqnorm(resid(model.arima),ylab="Sample Q",xlab="Theoretical Q")
qqline(resid(model.arima))

fore = forecast(model.arima,h=114)
fore=as.data.frame(fore)
point.fore = ts(fore[,1],start=c(2019),frequency=365.25)
lo.fore = ts(fore[,4],start=c(2019),frequency=365.25)
up.fore = ts(fore[,5],start=c(2019),frequency=365.25)
ymin=min(c(temp_train[(n-478):n],lo.fore))
ymax=max(c(temp_train[(n-478):n],up.fore))
plot(ts(dtemp[(n-478):n],start=c(2018),frequency=365.25),  ylab="Differenced Temperature", type="l",main="Predictions from ARIMA model")
points(point.fore,lwd=2,col="red")
lines(lo.fore,lty=3,lwd= 2, col="blue")
lines(up.fore,lty=3,lwd= 2, col="blue")
legend("topleft",c("Actual value","Estimated value","95% interval"), bty="n", lwd=c(1,2,2), col=c("black","red","blue"))

# VAR model

VARselect(data.train, lag.max = 20,type="both")$selection
model.var=VAR(data.train, p=8,type="both")
summary(model.var)

pred = predict(model.var, n.ahead=114, ci=0.95)[[1]]$dtemp
point.pred = ts(pred[,1],start=2019, freq=365.25)
lo.pred = ts(pred[,2],start=2019, freq=365.25)
up.pred = ts(pred[,3],start=2019, freq=365.25)

plot(ts(dtemp[(n-478):n],start=c(2018),frequency=365.25),  ylab="Differenced Temperature", type="l",main="Predictions from VAR Model")
points(point.pred,lwd=2,col="red")
lines(lo.pred,lty=3,lwd= 2, col="blue")
lines(up.pred,lty=3,lwd= 2, col="blue")
legend("topleft",c("Actual value","Estimated value","95% interval"), bty="n", lwd=c(1,2,2), col=c("black","red","blue"))

