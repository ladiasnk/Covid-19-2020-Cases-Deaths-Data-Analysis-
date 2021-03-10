%Nikolaos Ladias 
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
UK_cases=table2array(cases(147,64:217));
Netherland_cases=table2array(cases(97,64:194));
France_cases=table2array(cases(48,66:147));
Serbia_cases=table2array(cases(121,75:157));
%and country picked from the begining
Armenia_cases=table2array(cases(6,76:262));

U(1,1:length(Serbia_cases))=Serbia_cases;
U(2,1:length(Netherland_cases))=Netherland_cases;
U(3,1:length(UK_cases))=UK_cases;
U(4,1:length(Italy_cases))=Italy_cases;
U(5,1:length(France_cases))=France_cases;
U(6,1:length(Armenia_cases))=Armenia_cases;
%exact same procedure now for deaths 
UK_deaths=table2array(deaths(147,64:221));
Italy_deaths=table2array(deaths(67,56:198));
Netherland_deaths=table2array(deaths(97,76:194));
France_deaths=table2array(deaths(48,66:147));
Serbia_deaths=table2array(deaths(121,87:157));
Armenia_deaths=table2array(deaths(6,76:262));

M(1,1:length(Serbia_deaths))=Serbia_deaths;
M(2,1:length(Netherland_deaths))=Netherland_deaths;
M(3,1:length(UK_deaths))=UK_deaths;
M(4,1:length(Italy_deaths))=Italy_deaths;
M(5,1:length(France_deaths))=France_deaths;
M(6,1:length(Armenia_deaths))=Armenia_deaths;
max_delay=NaN(6,1);
best_correlation=zeros(6,1);
 corr_coefficients=zeros(50,6);  % 25+25 
for i=1:6
   country_cases=U(i,:);
   country_deaths=M(i,:);
   %look for best time delay in the interval -15,15 
%     country_deaths=M(i,:);
   for j=-25:25
       %if j<0 interpolate the new sample to match the new length for
       %deaths(basically SHIFT CURVE j units), then fill in the remaining
       %elements as 0 to reach cases length, because cases now had a bigger
       %length, and these two need to be equally sized to compute their
       %correlation coefficient
       if j<0
       new_country_deaths_sample=interp1(1:numel(country_deaths),country_deaths,...
   linspace(1,numel(country_deaths),numel(country_deaths)+j));
     
       reshape(new_country_deaths_sample,length(new_country_deaths_sample),1);
       new_country_deaths_sample(numel(country_cases)) = min(new_country_deaths_sample);
       
    coefficients=corrcoef(new_country_deaths_sample,country_cases);
       end
       %if j>=0 interpolate the new sample to match the new length for
       %deaths(basically SHIFT CURVE j units), now fill in the remaining
       %elements for cases as 0 to reach deaths length, because deaths sample 
       %now had a bigger
       %length, and these two need to be equally sized to compute their
       %correlation coefficient
       if j>=0
           
       new_country_deaths_sample=interp1(1:numel(country_deaths),country_deaths,...
       linspace(1,numel(country_deaths),numel(country_deaths)+j));
       reshape(new_country_deaths_sample,length(new_country_deaths_sample),1);
       country_cases(numel(new_country_deaths_sample)) = min(country_cases);

    coefficients=corrcoef(new_country_deaths_sample,country_cases);
   
       end
       %basic logic follows to store the coefficients to an array
       if j<0
        corr_coefficients(j+26,i)=coefficients(2,1);% add 26 to begin from index 1
       end
       if j>=0
           corr_coefficients(j+25,i)=coefficients(2,1);
       end
        
   end
   best_delay=find(corr_coefficients(:,i)==max(corr_coefficients(:,i)));
   best_correlation(i,1)=max(corr_coefficients(:,i));
   %store the maximum coefficient's place(and so the time delay) to an array 
  max_delay(i,1)=best_delay;
  %max index is stored in a array with a length of 50 so now to get the
  %real value of max delay we only have to subtract 25.
  max_delay(i,1)=max_delay(i,1)-25;
end
%visualise results
normalize(max_delay);
normalize(best_correlation);
figure(1);
bar(max_delay,'c');
xlabel('Country');
ylabel('Time delay in days');
set(gca, 'XtickLabel',countries );
title("Bargraph of optimal delays between cases and deaths that maximize their correlation");
figure(2);
bar(best_correlation,'g');
xlabel('Country');
ylabel('Correlation computed');
set(gca, 'XtickLabel',countries );
title('Ïptimal correlation coefficients computed between daily cases and time delayed daily deaths');
%By looking at the output difference computed , that maximized the
%correlation of these two distributions(deaths and cases for each country).
%The corr_coefficients array hold ALL correlation coefficients for all 50
%time delays [-25 25] for each of the 6 countries(6 collumns). The maximum
%correlation coefficient computed for each country is saved in the
%best_correlation array. These correlation coefficients are quite high.This 
%gives us enough space to state that this approach correctly assesses the delay 
%of the course of daily deaths in terms of the course of daily cases.
%These results do seem to deviate a lot from the initial previous ones, the main reason 
%for this cause is that the previous estimation by taking the difference of
%the maximum points of the curves of the best fitting distibutions is not a very precise
%and effective method. While the method used in this exercise maximized the
%correlation between a delayed daily deaths distribution and the daily
%cases distribution is a much better approach since maximizing correlation is a 
%great method to describe the relation between the two data sets for each country.
%The lack of precise prediction may appear due to the errors of the fitted
%distributions, even though they were the most proper ones according to
%RMSE values gained from the previous exercise.

% The main problems I encountered in this exercise is
%how to deal with the different lengths of the deaths array and cases array
%for each country. The idea was that I  shifted the cases curve ô(=delay)
%units each time and filled with zeros the remaining elements to each array
%that exceeded the proper length using the interpolation.This may have inserted errors
%to my approach but I was not able to find a better way to use regression
%functions for arrays of different lengths, even though I searched a lot.