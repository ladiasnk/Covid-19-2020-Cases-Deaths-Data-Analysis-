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
%deaths start to arrise continuously and end at the last value of our data (13/12).
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
adjRsquared=@(yestimate,y,n,k)  1- (n-1)/(n-1-k)*sum((yestimate-y).^2)/ sum( (y-mean(y)).^2);
adjR=zeros(6,2);
%best suited models computed from previous exercise
%1--_>simple linear model
%2--->multilinear model
%3--->step wise model
best_models=[1 2 3 3 2 3];
%best linear model for each country. Need to know that for countries that
%theire best model is the first one
best_linear_model=[20 24 1 1 1 1];
for i=1:6
    %gain data for country daily cases and deaths in both first and second
    %wave
    country_cases_1=first_wave_cases{i};
    country_deaths_1=first_wave_deaths{i};
    country_cases_2=second_wave_cases{i};
    country_deaths_2=second_wave_deaths{i};
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
         %variables array with all the 26 collumns for the multilinear
         %model.
   
    country_cases=country_cases_array{k};
    country_deaths=country_deaths_array{k};
%normalize both cases and deaths to bring both data sets to equal levels.
    country_cases=normalize(country_cases,'norm',1);
    country_deaths=normalize(country_deaths,'norm',1);
    new_country_cases_sample=interp1(1:numel(country_cases),country_cases,...
    linspace(1,numel(country_cases),numel(country_cases)-j));
    %fill array of country deaths or new cases sample according to which is
    %bigger with zeros, to equalize their sizes. Same for country deaths
    %and country cases, this is obligatory since we cannot preceed in any
    %of the following regressions without having equal lengths for country
    %cases and deaths and the new sample created. So I tried to equalize
    %them with an optimal way of adding zeros to the end of the one with
    %the smaller length.
    
 new_country_cases_sample=reshape(new_country_cases_sample,length(new_country_cases_sample),1);
 country_deaths=reshape(country_deaths,length(country_deaths),1);
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
 %if best model is the simple linear and the loop reached the best linear model(best delay) 
 %do it and save it to best model.
 if best_models(i)==1 && j==best_linear_model(i)     
    covar=cov(new_country_cases_sample,country_deaths);
     b1=covar(1,2)/var(new_country_cases_sample);
     b0=mean(country_deaths)-b1*mean(new_country_cases_sample);
     best_model_deaths=b0+b1*new_country_cases_sample;
      %compute adjusted R squared for the model
     adjR(i,k)=adjRsquared(best_model_deaths,country_deaths,length(country_deaths),1);
 end
 temp(:,j)=new_country_cases_sample;
   %reshape to concatenate arrays correctly
   country_cases=reshape(country_cases,length(country_cases),1);
   variables_array=[country_cases temp];
   %all variables linear regression
   Xreg=[ones(length(country_deaths),1) variables_array(:,:)];
   country_deaths=reshape(country_deaths,length(country_deaths),1);
   coefficients=regress(country_deaths,Xreg);
   %linear model created
   multi_linear_model=Xreg*coefficients;
   %if best model is the 2nd one then is the multi linear one
   if best_models(i)==2 
       best_model_deaths=multi_linear_model;
        %compute adjusted R squared for the model
       adjR(i,k)=adjRsquared(best_model_deaths,country_deaths,length(country_deaths),26);
   end
   if best_models(3)==3
       [step_wise_coefficients,~,~,model,stats]=stepwisefit(Xreg,country_deaths);
      b0=stats.intercept;
      step_wise_coefficients=[b0; step_wise_coefficients(model)];
      best_model_deaths=[ones(length(Xreg),1) Xreg(:,model)]*step_wise_coefficients; 
       %compute adjusted R squared for the model
adjR(i,k)=adjRsquared(best_model_deaths,country_deaths,length(country_deaths),length(step_wise_coefficients));
   end
   
   %first array consists errors for the first wave and second one for the second wave 
   if k==1
   errors_wave_1_array=(country_deaths-best_model_deaths);   
   else %second wave
   errors_wave_2_array=country_deaths-best_model_deaths;
   end % end if else
    end%end loop for looping for all 25 delays
    %plot standardised errors for both waves in subplots
   figure(i)
    if k==1
    plot1=subplot(2,1,1);
    plot(errors_wave_1_array,'O');
    printmsg_figure2=sprintf('Scatter plot of errors for %s during first wave',countries{1,i});
    ylabel('Errors');
    title(printmsg_figure2);
    end
    if k==2
    plot1=subplot(2,1,2);
    plot(errors_wave_2_array,'O');
    printmsg_figure2=sprintf('Scatter plot of errors for %s during second wave',countries{1,i});
    ylabel('Errors');
    title(printmsg_figure2);
    end
    
    end% end loop for both waves
    
end%end loop for coutntries
%By having a look at the adjR array, the first collumn consits of the
%adjusted R squared  for the model used for each one of the 6 countries in its rows for the
%first wave while the second one for the second wave. Looking at the table in general,
%the fit of the best model we calculated in question 6 for each country, is better in the 
%learning set (first wave), than in the evaluation set (second wave). Apart from Serbia 
%and Armenia.
%That means that generally speaking, trying to predict daily deaths from daily cases 
%using a model found for a given time period and applying that model to later  
%time periods after the first wave is a good idea since adjR doesn't deviate a lot
%and can even seem to be better. However, the best-fitted model for each
%country for the first wave is not necessarily suitable to make predictions in another wave.
%Other waves in later time periods may differ in the time relations between
%daily cases distribution and daily deaths distribution and that may lead in less adaptability
%of the model.

