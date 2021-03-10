%Nikolaos Ladias
%(9362mod156+1=3=Algeria,nearest European=Albania->not much and satisfying data->Armenia(nearest European)
%first clear all my variables 
clear variables;
clear all;
clc;
workspace;
clear figures;
%now import data from excel as seperate column vectors
data=readtable('Covid19Deaths.xlsx');
%choose all numeric values for country indexed as 6 and columns 
%with an index bigger than 4(4th column=population)
data_daily_deaths=table2array(data(6,4:end));
%remove all NaN values from array
data_daily_deaths=data_daily_deaths(~isnan(data_daily_deaths));


%same way first wave was defined for confirmed cases for armenia, the first
%wave for daily deaths is coincidentally (could be different dates) the
%same dates defined for first wave for daily confirmed cases
data_daily_deaths=data_daily_deaths(72:258);
Y=data_daily_deaths;
X=1:1:length(data_daily_deaths);
%reshape both X and Y to a vector form 
X=reshape(X,length(X),1);


distributions={'Nakagami','GeneralizedExtremeValue','Rayleigh','Rician','Normal'};
%function handle to quickly compute Rsquared 
Rsquared=@(yestimate,y) 1-sum((yestimate-y).^2)/sum((y-mean(y)).^2);
Rsq=zeros(5,1);
%for every distribution experimented in this script,after the data are
%being scaled to a proper degree to fit in the pdf generated through
%fitdist (which outputs the proper distribution object), a difference between
%those two sets is set to a temporary variable and the RMSE
%value is computed for each model

%there are several ways to find out how to scale properly our dataset to
%fit our output pdf, in this script basically the local(mabye even total) minimum of a
%function that is defined properly to compute the minimum of it's variable k. The function uses k
%as a scalar of a squared difference of the two datasets. Once this best
%scalar is found , it is used to scale down the given data to fit the
%corresponding pdf of the distribution object.

%first distribution is a GenerelizedExtremeValue 
dist=fitdist(X,'Nakagami','frequency',data_daily_deaths);
yFitted1=pdf(dist,X);
yFitted1=reshape(yFitted1,1,length(yFitted1));
sse=@(k,dataset1,dataset2) sum((dataset1-k*dataset2).^2);
rmse=NaN(1,5);
%starting point for fminsearch
x0=1;
%function
fun=@(x) sse(x,Y,yFitted1);
best_scale_factor=fminsearch(fun,x0);
%normalize data  according to best scalar factor
Y=normalize(Y,'scale',best_scale_factor);
bar(Y);
%errors computed , then RMSE
%errors for every model are:error=normalized original values-values gained from pdf
errors=Y-yFitted1;
rmse(1,1)=sqrt(1/(length(data_daily_deaths)-2)*sum(errors.^2) );
Rsq(1,1)=Rsquared(yFitted1,Y);
hold on;
plot(X,yFitted1,'LineWidth',2);
hold on;
%second model is a gamma distribution model

dist=fitdist(X,'GeneralizedExtremeValue','frequency',data_daily_deaths);
yFitted2=pdf(dist,X);
yFitted2=reshape(yFitted2,1,length(yFitted2));
fun=@(x) sse(x,Y,yFitted2);
best_scale_factor=fminsearch(fun,x0);
errors=Y-yFitted2;
rmse(1,2)=sqrt(1/(length(Y)-2)*sum(errors.^2) );
Rsq(2,1)=Rsquared(yFitted2,Y);
Y=normalize(Y,'scale',best_scale_factor);
plot(X,yFitted2,'LineWidth',2);
hold on;
%third model is a rayleigh distribution model
dist=fitdist(X,'Rayleigh','frequency',data_daily_deaths);
yFitted3=pdf(dist,X);
yFitted3=reshape(yFitted3,1,length(yFitted3));
fun=@(x) sse(x,Y,yFitted3);
best_scale_factor=fminsearch(fun,x0);
errors=Y-yFitted3;
rmse(1,3)=sqrt(1/(length(Y)-2)*sum(errors.^2) );
Rsq(3,1)=Rsquared(yFitted3,Y);
Y=normalize(Y,'scale',best_scale_factor);
plot(X,yFitted3,'LineWidth',2);
hold on;
%fourth model is a Rician distribution model
dist=fitdist(X,'Rician','frequency',data_daily_deaths);
yFitted4=pdf(dist,X);
yFitted4=reshape(yFitted4,1,length(yFitted4));
fun=@(x) sse(x,Y,yFitted4);
best_scale_factor=fminsearch(fun,x0);
errors=Y-yFitted4;
rmse(1,4)=sqrt(1/(length(Y)-2)*sum(errors.^2) );
Rsq(4,1)=Rsquared(yFitted4,Y);
Y=normalize(Y,'scale',best_scale_factor);
plot(X,yFitted4,'LineWidth',2);
%fifth model is a normal distribution model
dist=fitdist(X,'Normal','frequency',data_daily_deaths);
yFitted5=pdf(dist,X);
yFitted5=reshape(yFitted5,1,length(yFitted5));
fun=@(x) sse(x,Y,yFitted5);
best_scale_factor=fminsearch(fun,x0);
errors=Y-yFitted5;
rmse(1,5)=sqrt(1/(length(Y)-2)*sum(errors.^2) );
Rsq(5,1)=Rsquared(yFitted5,Y);
Y=normalize(Y,'scale',best_scale_factor);
plot(X,yFitted5,'LineWidth',2);

%finallly legend and title is put to the plotted distributions
legend('Bargraph','Nakagami','GeneralizedExtremeValue model','Rayleigh model','Rician model','Normal model');
title('Bargraph of confirmed cases for Armenia during first wave hit')
%find best model's index(minimum RMSE=best model)
best_model=find(rmse==min(rmse));
message_console=sprintf('Best model is the %s model distribution with an R squared value of %4.4f',distributions{best_model},Rsq(best_model));
 disp(message_console);
%The adjustment statistical error used to decide the best fitted model is
 %the R squared. The model that produced the biggest R squared is the best
 %fitted one for our daily deaths distribution. RMSE values are also
 %computed for a more complete picture of the model's perfomance. It is our
 %final conclusion that the same model(Nakagami distribution, out of the 5 that are chosen)
 %is used to more fully describe both daily new cases and daily new
 %deaths through the course of the first wave for Armenia, since it produces the biggest
 %R squared for both daily cases and daily deaths distribution for Armenia. 