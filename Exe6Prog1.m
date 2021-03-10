%Nikolaos Ladias
%clear variables,figures, cloase anything running and make sure workspace works normally
clear variables;
clear all;
clear figures;
clc;
close all;

workspace;
%import Deaths and Confirmed Cases data. follow the exact same procedure
%with arrays that hold up all the countries values as before
deaths=readtable('Covid19Deaths.xlsx');
cases=readtable('Covid19Confirmed.xlsx');
countries={'Serbia','The Netherlands','UK','Italy','France','Armenia'};
UK_cases=table2array(cases(147,64:217));
Italy_cases=table2array(cases(67,56:175));
Netherland_cases=table2array(cases(97,64:194));
France_cases=table2array(cases(48,66:147));
Serbia_cases=table2array(cases(121,75:157));
Armenia_cases=table2array(cases(6,76:262));
%U=cell array,each cell is the cases array for each country
U{1}=Serbia_cases;
U{2}=Netherland_cases;
U{3}=UK_cases;
U{4}=Italy_cases;
U{5}=France_cases;
U{6}=Armenia_cases;

%exact same procedure now for deaths 
UK_deaths=table2array(deaths(147,64:221));
Italy_deaths=table2array(deaths(67,56:198));
Netherland_deaths=table2array(deaths(97,76:194));
France_deaths=table2array(deaths(48,66:147));
Serbia_deaths=table2array(deaths(121,87:157));
Armenia_deaths=table2array(deaths(6,76:262));
%same procedure with deaths, group them into one cell array
M{1}=Serbia_deaths;
M{2}=Netherland_deaths;
M{3}=UK_deaths;
M{4}=Italy_deaths;
M{5}=France_deaths;
M{6}=Armenia_deaths;
best_linear_model=[20 24 1 1 1 1];%best delays found for each country according to linear regression
%modeling from previous exercise
rmse_array=zeros(6,3);
adjR=zeros(6,3);
adjRsquared=@(yestimate,y,n,k)  1- (n-1)/(n-1-k)*sum((yestimate-y).^2)/ sum( (y-mean(y)).^2);
for i=1:6
  country_cases=U{i};
  country_deaths=M{i};
  %Normalize BOTH deaths and cases to only care about the trend that deaths
  %take depending on the cases and  to not get lost
  %in the order of magnitude of the data sets.
  country_cases=normalize(country_cases,'norm',1);
  country_deaths=normalize(country_deaths,'norm',1);
  country_deaths=reshape(country_deaths,length(country_deaths),1); 
    figure(i);
 %temp array is created to store all the single linear regressions for
 %every delay in the interval [1,25] this array is concatenated along with 
 %country cases initial values for each country to finally have the entire
 %variables array with all the 26 collumns .
  temp=[];
  errors=0;
for j=1:25
    new_country_cases_sample=interp1(1:numel(country_cases),country_cases,...
    linspace(1,numel(country_cases),numel(country_cases)-j));
    %fill array of country deaths or new cases sample according to which is
    %bigger with zeros, to equalize their sizes
    while length(country_deaths)~=length(new_country_cases_sample)
       if length(country_deaths)<length(new_country_cases_sample)
         country_deaths(end+1)=0;
       else 
         new_country_cases_sample(end+1)=0;  
       end
    end
 
  new_country_cases_sample=reshape(new_country_cases_sample,length(new_country_cases_sample),1);
  if j==best_linear_model(i)
     %create the simple linear model for that best model to compute rmse and
     %standard errors
     new_country_cases_sample=reshape(new_country_cases_sample,length(new_country_cases_sample),1);
     covar=cov(new_country_cases_sample,country_deaths);
     b1=covar(1,2)/var(new_country_cases_sample);
     b0=mean(country_deaths)-b1*mean(new_country_cases_sample);
     lin_model_deaths=b0+b1*new_country_cases_sample;
     errors=country_deaths-lin_model_deaths;
     rmse_array(i,1)=sqrt(1/(length(country_deaths)-2)*sum(errors.^2) );
     adjR(i,1)=adjRsquared(lin_model_deaths,country_deaths,length(country_deaths),1);
     plot(errors./rmse_array(i,1),'*');
     hold on;
  end
     %variables array containing every shifted by ô units country cases(replaced remaining
     %values to have equal lengths with zeros) 
     temp(:,j)=new_country_cases_sample;
end
   %first fill temp array or country cases array with zeros according to their difference in
   %length to match their sizes so they can be concatenated,since variables
   %final array will hold original country cases data in first collumn.Then do the
   %same for country deaths for the same reason.
   while length(country_cases)~=length(temp)
       if length(country_cases)<length(temp)
         country_cases(end+1)=0;
       else 
         temp(end+1,:)=0;  
       end
   end
    while length(country_deaths)~=length(temp)
       if length(country_deaths)<length(temp)
         country_deaths(end+1)=0;
       else 
         temp(end+1,:)=0;  
       end
   end  
   %reshape to concatenate arrays correctly
   country_cases=reshape(country_cases,length(country_cases),1);
   variables_array=[country_cases temp];
   %all variables linear regression
   Xreg=[ones(length(country_deaths),1) variables_array(:,:)];
   country_deaths=reshape(country_deaths,length(country_deaths),1);
   coefficients=regress(country_deaths,Xreg);
   multi_linear_model=Xreg*coefficients;
   errors=country_deaths-multi_linear_model;
   rmse_array(i,2)=sqrt(1/(length(country_deaths)-2)*sum(errors.^2) );
   adjR(i,2)=adjRsquared(multi_linear_model,country_deaths,length(country_deaths),26);
   plot(errors./rmse_array(i,2),'*'); 
   hold on;
   %step wise regression   
      [step_wise_coefficients,~,~,model,stats]=stepwisefit(Xreg,country_deaths);
      b0=stats.intercept;
      step_wise_coefficients=[b0; step_wise_coefficients(model)];
      step_wise_regression=[ones(length(Xreg),1) Xreg(:,model)]*step_wise_coefficients;
      errors=country_deaths-step_wise_regression;
      rmse_array(i,3)=sqrt(1/(length(country_deaths)-2)*sum(errors.^2) );
      plot(errors./rmse_array(i,3),'O'); 
     adjR(i,3)=adjRsquared(step_wise_regression,country_deaths,length(country_deaths),length(step_wise_coefficients));
      hold on
       
      msg_title=sprintf("Standard errors for various regression models for %s", countries{i});
      title(msg_title);
      legend('standard errors for simple linear regression',...
 'standard errors for regression model including all delays in interval [0 25]','Standard errors for stepwise regression model');
plot([0,length(country_deaths)],[-1.96 -1.96],'HandleVisibility','off');
   hold on;
   plot([0,length(country_deaths)],[1.96 1.96],'HandleVisibility','off');     
end
%OUTPUT RMSE ARRAY:
%1st collumn:rmse values for best linear model for each country
%2nd collumn:rmse values for all variables multilinear regressio model for
%each country
%3rd collumn:rmse values for stepwise regression model for each country
%adjR is constructed with the same way.
%It is easily noticeable by having a look at the RMSE table that the
%multilinear regression approach is a better one since it always produces a
%smaller RMSE value .   
%For some countries ,the errors form a curve at the beginning but they also 
%seem quite random afterwards. 
%So this also implies that perhaps the dependence may be non-linear for some time periods. I am
%using the adjusted R squared to judge which model is better suited for
%each country. Running the script I conclude using the adjR array that
%those are the final models more suitable for each country:
%1:Serbia -->1st model--->simple linear model
%2:The Netherlands--->2nd model--->multilinear  model
%3:UK--->3rd model--->step wise model
%4:Italy--->3rd model-->step wise model
%5:France--->2nd model---> multilinear model
%6:Armenia--->3rd model--->step wise model