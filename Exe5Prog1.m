%clear variables,figures and make sure workspace works normally
clear variables;
clear all;
clear figures;
clc;
workspace;
%import Deaths and Confirmed Cases data. follow the exact same procedure
%with arrays that hold up all the countries values as before
deaths=readtable('Covid19Deaths.xlsx');
cases=readtable('Covid19Confirmed.xlsx');
countries={'Serbia','The Netherlands','UK','Italy','France','Armenia'};
Italy_cases=table2array(cases(67,56:175));
Netherland_cases=table2array(cases(97,64:194));
France_cases=table2array(cases(48,66:147));
Serbia_cases=table2array(cases(121,75:157));
Armenia_cases=table2array(cases(6,76:262));
UK_cases=table2array(cases(147,64:217));
%group them all in one array
%one cell array,each element is a double array of its own size
U{1}=Serbia_cases;
U{2}=Netherland_cases;
U{3}=UK_cases;
U{4}=Italy_cases;
U{5}=France_cases;
U{6}=Armenia_cases;
%exact same procedure now for deaths 

Italy_deaths=table2array(deaths(67,56:198));
Netherland_deaths=table2array(deaths(97,76:194));
France_deaths=table2array(deaths(48,66:147));
Serbia_deaths=table2array(deaths(121,87:157));
Armenia_deaths=table2array(deaths(6,76:262));
UK_deaths=table2array(deaths(147,64:221));

M{1}=Serbia_deaths;
M{2}=Netherland_deaths;
M{3}=UK_deaths;
M{4}=Italy_deaths;
M{5}=France_deaths;
M{6}=Armenia_deaths;
best_delay=NaN(6,1);
for i=1:6
 %select country cases and deaths from the array that holds them 
 country_cases=U{i}  ;
 country_deaths=M{i};   
 rmse_array=zeros(20,1);
 errors=cell(20,1);
 all_models={};
   for j=1:25
    %interpolate the sample to shift it j units right
    new_country_cases_sample=interp1(1:numel(country_cases),country_cases,...
    linspace(1,numel(country_cases),numel(country_cases)-j));
    %simply reshape in the form of vector
    new_country_cases_sample=reshape(new_country_cases_sample,length(new_country_cases_sample),1);
    %fill array of country deaths or new cases sample according to which is
    %bigger with zeros, to equalize their sizes
    while length(country_deaths)~=length(new_country_cases_sample)
       if length(country_deaths)<length(new_country_cases_sample)
         country_deaths(end+1)=0;
       else 
         new_country_cases_sample(end+1)=0;  
       end
    end
    %reshape deaths sample too
    country_deaths=reshape(country_deaths,length(country_deaths),1);
    %now use fit linear model, compute betas and then the model
    model=fitlm(new_country_cases_sample,country_deaths);
    betas=table2array(model.Coefficients);
    betas=betas(:,1);
    lin_model_deaths=[ones(length(new_country_cases_sample),1) new_country_cases_sample]*betas;
    %compute errors and save rmse to rmse array
    errors{j}=country_deaths-lin_model_deaths;
    rmse_array(j,1)=sqrt(1/(length(country_deaths)-2)*sum(errors{j}.^2) );
    figure(i)
    std_error=errors{j}./rmse_array(j,1);
    %plot standardized errors
    xFitted=1:1:length(std_error);
    plot1=subplot(2,1,1);
    plot(xFitted,std_error,'O')
    all_models{j}=lin_model_deaths;
    all_new_samples{j}=new_country_cases_sample;
     hold on;
   end
   %best model gives minimum RMSE value, choose that, and plot it
   best_delay(i)=find(rmse_array==min(rmse_array));
   %standardized errors
   standard_error=errors{best_delay(i)}./rmse_array(best_delay(i));
   printmsg=sprintf('Standard errors for %s for delays in interval [0,25]\n Line belongs to the delay with the smallest RMSE',countries{1,i});
   title(plot1,printmsg);
   xaxis=1:1:length(standard_error);
   plot(xaxis,standard_error,'LineWidth',2)
   hold on;
   line([0,length(country_deaths)],[-1.96 -1.96]);
   hold on;
   line([0,length(country_deaths)],[1.96 1.96]);
   hold off;
   %find best model to plot for this country
   model_to_plot=all_models{best_delay(i)};
   %just make sure country cases and model to plot has same length by
   %adding a zero if needed where needed.
   while length(country_deaths)~=length(model_to_plot)
       if length(country_deaths)<length(model_to_plot)
         country_cases(end+1)=0;
       else 
         model_to_plot(end+1)=0;  
       end
   end
   %ready to plot
   plot2=subplot(2,1,2);
   msg2=sprintf('Predicted daily deaths according to best linear model for %s',countries{1,i});
   title(msg2);
   scatter(country_deaths,model_to_plot); 
   xlabel('Daily deaths');
   ylabel('Predicted daily deaths')
end
%If we are to guess that because of the negative difference found for
%countries Italy,France and Armenia the best delay found is 1 which
%theoretically and practically is correct since no positive difference between cases and
%deaths found from exercise 3 for these countries. Therefore, the best
%delay that fits the "greatest" predictions for these countries should
%finish in the loop in the first delay(which is closer to negative delays
%than any other delay). For countries Serbia, Netherlands and UK dealys predicted are quite
%close to the ones predicted in exercise 4. All the
%standard errors from every simple linear model for every delay in the
%interval [0 25] are plotted in the same figure for every country (so as not to plot 26
%different figures for each country) and the line belongs to the model with the smallest
%RMSE. Each figure also has a subplot of the country's predicted deaths
%with real daily death values in x axis for the best simple linear model exported 
%for the same country.
%The fitting model does not seem to have the same efficiency for every
%country. The optimal modeling lags agree with the optimal lags from the correlation
%in Question 4 but of course not with the peak difference in Question 3 for
%the countries tested.The diagnostic test indicates the suitability 
%of the model for different lags and countries. There are several minor
%issues
%that I encountered with the diagnostic test. For example some points lie 
%outside the borderlines,
%while some errors are much bigger than others. Therefore I could not state
%with certainty that we could predict daily deaths by looking at previously
%dated daily new cases.