%Nikolaos Ladias
%clear variables,figures and make sure workspace works normally
clear variables;
clear all;
clear figures;
clc;
workspace;
%import Deaths and Confirmed Cases data
deaths=readtable('Covid19Deaths.xlsx');
cases=readtable('Covid19Confirmed.xlsx');
%remove first 3 collumns 
deaths=deaths(:,3:end);
cases=cases(:,3:end);
%first wave data for each country cases
countries={'Serbia','The Netherlands','UK','Italy','France','Armenia'};
UK_cases_1=table2array(cases(147,64:217));
Italy_cases_1=table2array(cases(67,56:175));
Netherland_cases_1=table2array(cases(97,64:194));
France_cases_1=table2array(cases(48,66:147));
Serbia_cases_1=table2array(cases(121,75:157));
Armenia_cases_1=table2array(cases(6,76:262));

UK_deaths_1=table2array(deaths(147,64:221));
Italy_deaths_1=table2array(deaths(67,56:198));
Netherland_deaths_1=table2array(deaths(97,76:194));
France_deaths_1=table2array(deaths(48,66:147));
Serbia_deaths_1=table2array(deaths(121,87:157));
Armenia_deaths_1=table2array(deaths(6,76:262));
%first wave cases array defined as before
first_wave_cases{1}=Serbia_cases_1;
first_wave_cases{2}=Netherland_cases_1;
first_wave_cases{3}=UK_cases_1;
first_wave_cases{4}=Italy_cases_1;
first_wave_cases{5}=France_cases_1;
first_wave_cases{6}=Armenia_cases_1;
%same now for deaths defined as before
first_wave_deaths{1}=Serbia_deaths_1;
first_wave_deaths{2}=Netherland_deaths_1;
first_wave_deaths{3}=UK_deaths_1;
first_wave_deaths{4}=Italy_deaths_1;
first_wave_deaths{5}=France_deaths_1;
first_wave_deaths{6}=Armenia_deaths_1;
%second wave values for each country cases defined to at least contain the
%maximum value noticed for cases or deaths, start from when the cases or
%deaths start to arrise continiously and end at the last value of our data (13/12).
%or when the cases or deaths fall a lot compared to the maximum value they
%had during the wave or when they fall to almost zero.
UK_cases_2=table2array(cases(147,240:335));
Armenia_cases_2=table2array(cases(6,268:end));
France_cases_2=table2array(cases(48,225:end));
Italy_cases_2=table2array(cases(67,271:end));
Serbia_cases_2=table2array(cases(121,168:252));
Netherland_cases_2=table2array(cases(97,226:end));

UK_deaths_2=table2array(deaths(147,274:end));
Armenia_deaths_2=table2array(deaths(6,274:end));
France_deaths_2=table2array(deaths(48,258:end));
Italy_deaths_2=table2array(deaths(67,288:end));
Serbia_deaths_2=table2array(deaths(121,178:244));
Netherland_deaths_2=table2array(deaths(97,226:end));

%deaths for each country in second wave 

second_wave_cases{1}=Serbia_cases_2;
second_wave_cases{2}=Netherland_cases_2;
second_wave_cases{3}=UK_cases_2;
second_wave_cases{4}=Italy_cases_2;
second_wave_cases{5}=France_cases_2;
second_wave_cases{6}=Armenia_cases_2;
%same procedure for second wave deaths
second_wave_deaths{1}=Serbia_deaths_2;
second_wave_deaths{2}=Netherland_deaths_2;
second_wave_deaths{3}=UK_deaths_2;
second_wave_deaths{4}=Italy_deaths_2;
second_wave_deaths{5}=France_deaths_2;
second_wave_deaths{6}=Armenia_deaths_2;
%array to hold all adjusted R squared values for each country in both waves
%and array to hold number of features for each country for the pcr
%regression model.
adjR=zeros(length(countries),2);
n0_features=zeros(length(countries),2);
adjRsquared=@(yestimate,y,n,k)  1- (n-1)/(n-1-k)*sum((yestimate-y).^2)/ sum( (y-mean(y)).^2);
%best model taken from exercise 6 is the 21 variables multilinear regression model since
%its efficiency is better than the 2 other models according to RMSE value.
for i=1:length(countries)
    %gain data for country daily cases and deaths in both first and second
    %wave
    country_cases_1=first_wave_cases{1,i};
    country_deaths_1=first_wave_deaths{1,i};
    country_cases_2=second_wave_cases{1,i};
    country_deaths_2=second_wave_deaths{1,i};
    %find maximum value of cases in second wave and in first wave and find
    %the difference. Then use this difference to subtract it from the
    %second wave values for cases since in every country daily cases in second
    %wave are much larger than the first wave ones. By subtracting the
    %diffference between their maximum values we try to normalize our
    %second wave values to have the comparison made much more balanced.
    
    country_cases_array={country_cases_1 ,country_cases_2};
    country_deaths_array={country_deaths_1, country_deaths_2};
    %loop through both waves by looping through these arrays for daily
    %cases and daily deaths , same procedure as in exercsise 6 follows
    for k=1:2
         temp=[]; 
    for j=1:25
         %temp array is created to store all the single linear regressions for
         %every delay in the interval [1,25] this array is concatenated along with 
         %country cases initial values for each country to finally have the entire
         %variables array with all the 26 collumns
  
    country_cases=country_cases_array{k};
    country_deaths=country_deaths_array{k};
%normalize both cases and deaths to bring both data sets to equal levels.
    country_cases=normalize(country_cases,'norm',1);
    country_deaths=normalize(country_deaths,'norm',1);
    new_country_cases_sample=interp1(1:numel(country_cases),country_cases,...
    linspace(1,numel(country_cases),numel(country_cases)-j));
    %fill array of country deaths or new cases sample according to which is
    %bigger with zeros, to equalize their sizes .This is obligatory since we 
    %cannot preceed in any regression without having equal lengths for country
    %cases and deaths and the new sample created. So I tried to equalize
    %them with an optimal way of adding zeros to the end of the one with
    %the smaller length.
new_country_cases_sample=reshape(new_country_cases_sample,length(new_country_cases_sample),1);
   while length(country_deaths)~=length(country_cases)
       if length(country_deaths)<length(country_cases)
         country_deaths(end+1)=0;
       else 
         country_cases(end+1)=0;  
       end
   end
    
    while length(country_deaths)~=length(new_country_cases_sample)
       if length(country_deaths)<length(new_country_cases_sample)
         country_deaths(end+1)=0;
       else 
         new_country_cases_sample(end+1,:)=0;  
       end
    end 
 temp(:,j)=new_country_cases_sample;
   %reshape to concatenate arrays correctly
   country_cases=reshape(country_cases,length(country_cases),1);
   country_deaths=reshape(country_deaths,length(country_deaths),1);
   variables_array=[country_cases temp];
   %all variables linear regression
  Xreg=[ones(length(country_deaths),1) variables_array(:,:)];
  covMatrix=cov(Xreg);
  [eigenVectors,eigenValues] = eig(covMatrix);
  eigenValues = diag(eigenValues);
  eigenValues = eigenValues(end:-1:1);
  %eigenVectors = eigenVectors(:,end:-1:1);--->optional to compute
  
%to compute number of components sum up the given significance for every
%eigenvalue by dividing with the current sum until that reaches a
%reasonable value (for example 90%)
significance_value_to_reach = 95;
eigenValuesSum = sum(eigenValues);
summary = 0;
n0_features(i,k) = 0;
%need to calculate number of feautures for the regression, save it to an
%array
while(summary < significance_value_to_reach)
    n0_features(i,k) = n0_features(i,k) + 1;
    summary = summary + 100*eigenValues(n0_features(i,k))/eigenValuesSum;
end
    end
nComponents = n0_features(i,k);
[~,~,Xscores,~,bPLS,PCTVAR] = plsregress(variables_array,country_deaths,nComponents);
n=length(variables_array);
figure(i);
%the second row of PCTVAR contains the percentage of variance explained in Y.
if k==1
plot1_pls=subplot(2,1,1);
 plot(1:length(PCTVAR(2,:)),cumsum(100*PCTVAR(2,:)),'-bo');
 printmsg_figure1=sprintf('Scree plot for %s durint first wave', countries{1,i});
 title(printmsg_figure1);
 ylabel('Percent variance explained in y');
 xlabel('Number of PLS components');
end
if k==2
   plot2_pls=subplot(2,1,2);
   plot(1:length(PCTVAR(2,:)),cumsum(100*PCTVAR(2,:)),'-bo');
   printmsg_figure1=sprintf('Scree plot for %s during second wave', countries{1,i});
   title(printmsg_figure1);
   ylabel('Percent variance explained in y');
   xlabel('Number of PLS components');
end
%figure to plot death estimates produced from the model along with the real
%ones, also compute the corresponding adjusted R squared.
y_estimate = [ones(n,1) variables_array]*bPLS;
adjR(i,k) = adjRsquared(y_estimate,country_deaths,length(country_deaths),nComponents);
figure(i+6);
if k==1
plot1_scatter=subplot(2,1,1);
plot(country_deaths,y_estimate,'O');
printmsg_figure2=sprintf('Scatter plot of fitted values and real daily deaths values for %s during first wave',countries{1,i});
xlabel('Real daily deaths values');
ylabel('Fitted values');
title(printmsg_figure2);
end
if k==2
plot2_scatter=subplot(2,1,2);
plot(country_deaths,y_estimate,'O');
printmsg_figure2=sprintf('Scatter plot of fitted values and real daily deaths values for %s during second wave',countries{1,i});
xlabel('Real daily deaths values');
ylabel('Fitted values');
title(printmsg_figure2);
end
    end%end for both waves
end% loop for coutntries
%By having a look at the adjR array, the first collumn consits of the
%adjusted R squared  for each one of the 6 countries in its rows for the
%first wave while the second one for the second wave. In this script the
%method for dimentionalityr reduction is PLS regression.Partial least-squares (PLS) 
%regression is a technique used with data that contain correlated predictor variables. 
%This technique constructs new predictor variables, known as components, as linear 
%combinations of the original predictor variables. PLS constructs these components 
%while considering the observed response values, leading to a parsimonious model 
%with reliable predictive power.The technique is something of a cross between multiple 
%linear regression and principal component analysis.Choosing the number of components 
%in a PLS model is a critical step. The plot gives a rough indication, showing
%nearly 90% of the variance in y explained by the first component, with as many
%as possible additional components making significant contributions. A Plot for 
%the percent of variance explained in the response variable as a function of the 
%number of components for each country is produced along with a scatter plot showing the 
%correlation between real daily death values and fitted values using PLS model for every country.
%Both figures contain the corresponding things mentioned in two subplots
%for the first and second wave. It is also observable that the change in adjusted R
%squared from first wave to second wave analysis depends on the country.
%For example for Serbia this adjustment factor becomes much greater while
%for Italy and Armenia it slightly rises. For the rest 3 countries it is
%reduced for the second wave. The worst prediction happens for The
%Netherlands where the adjustment coefficient is greatly reduced.