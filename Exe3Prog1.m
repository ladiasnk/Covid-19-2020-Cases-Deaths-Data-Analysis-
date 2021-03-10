%Nikolaos Ladias
%clear variables,figures and make sure workspace works normally
clear variables;
clear all;
clear figures;
clc;
workspace;
%import Deaths and Confirmed Cases data
deaths=readtable("Covid19Deaths.xlsx");
cases=readtable("Covid19Confirmed.xlsx");
%choose appropirate data for each country just as before (same dates), create a new
%array that holds all of these countries(confirmed cases)
France_cases=table2array(cases(48,66:147));
Germany_cases=table2array(cases(52,73:168));
UK_cases=table2array(cases(147,64:217));
Spain_cases=table2array(cases(130,64:134));
Ireland_cases=table2array(cases(65,67:172));
Italy_cases=table2array(cases(67,56:175));
Austria_cases=table2array(cases(8,62:134));
Belgium_cases=table2array(cases(13,68:172));
Netherland_cases=table2array(cases(97,64:194));
Serbia_cases=table2array(cases(121,75:157));
Armenia_cases=table2array(cases(6,76:262));
%create the cell array that holds in every data gained for every country
%the cell array can contain different sized arrays of type double in its
%indexes and that is the reason it is used
U=cell(1,6);
U{1}=Germany_cases;
U{2}=Italy_cases;
U{3}=UK_cases;
U{4}=Belgium_cases;
U{5}=Serbia_cases;
U{6}=Austria_cases;
U{7}=Ireland_cases;
U{8}=France_cases;
U{9}=Spain_cases;
U{10}=Netherland_cases;
U{11}=Armenia_cases;
%exact same procedure now for deaths 
France_deaths=table2array(deaths(48,66:147));
Germany_deaths=table2array(deaths(52,73:168));
UK_deaths=table2array(deaths(147,64:221));
Spain_deaths=table2array(deaths(130,69:134));
Ireland_deaths=table2array(deaths(65,87:141));
Italy_deaths=table2array(deaths(67,56:198));
Austria_deaths=table2array(deaths(8,80:113));
Belgium_deaths=table2array(deaths(13,77:186));
Netherland_deaths=table2array(deaths(97,76:194));
Serbia_deaths=table2array(deaths(121,87:157));
Armenia_deaths=table2array(deaths(6,76:262));
%final array for deaths
deaths_durations=[length(Germany_deaths) length(France_deaths) length(UK_deaths) length(Spain_deaths) ...
length(Ireland_deaths) length(Italy_deaths) length(Austria_deaths) length(Belgium_deaths) length(Netherland_deaths)...
length(Serbia_deaths) length(Armenia_deaths)];
max_duration=max(deaths_durations);
%sam thing for every deaths data arrays for every country ,create M, the
%cell array that can contain all these different sized arrays of type
%double
M=cell(1,6);
M{1}=Germany_deaths;
M{2}=Italy_deaths;
M{3}=UK_deaths;
M{4}=Belgium_deaths;
M{5}=Serbia_deaths;
M{6}=Austria_deaths;
M{7}=Ireland_deaths;
M{8}=France_deaths;
M{9}=Spain_deaths;
M{10}=Netherland_deaths;
M{11}=Armenia_deaths;
%In this script computes the maximum point for daily cases and daily deaths
%according to the fitted distribution.
for i=1:11
   X=1:1:length(U{1,i});
   X=reshape(X,length(X),1); 
   Y=U{1,i};
   %replace negative values with their absolute value, fitdist needs this or else it
   %raises an error
   Y(Y<0)=abs(Y(Y<0));
   Y=reshape(Y,length(Y),1);
   %best fit for cases was Nakagami distribution
   dist=fitdist(X,'Nakagami','frequency',Y);
   yFitted=pdf(dist,X);
   %compute pdf and find where its maximum value is
   %NOTED: THE EXERCISE ASKS FOR A FUNCTION SAME AS THE PREVIOUS SCRIPT BUT
   %WITH ONLY DIFFERENCE THE COMPUTATION OF THE MAXIMUM VALUES OF THE
   %CURVES AND THEIR DIFFERENCES.I MADE THIS SCRIPT WHICH DOES EXACTLY THE
   %SAME OPERATIONS FOR CASES AND DEATHS AND DOES THE REQUESTED AS TOLD.
   max_cases(i)=find(yFitted==max(yFitted));
   
   
   %same procedure for deaths, best model was Normal distribution
   X=1:1:length(M{1,i});
   X=reshape(X,length(X),1); 
   Y=M{1,i};
   Y=reshape(Y,length(Y),1);
   %replace negative values appeared, by their absolute value, negative
   %values were only noticed in data imported for Spain specifically, and
   %so I believe these values were meant to be positive but mabye some
   %error in dataset lead to their negative sign and that was the way i dealt with them.
   Y(Y<0)=abs(Y(Y<0));
   %best fit for deaths was Nakagami distribution
   dist=fitdist(X,'Nakagami','frequency',Y);
   yFitted=pdf(dist,X);
   max_deaths(i)=find(yFitted==max(yFitted));
   difference(i)=max_cases(i)-max_deaths(i);
end
%compute parametric and bootstrap 95% confidence intervals
[~,~,ci_parametric,~]=ttest(difference);
%define number of bootstrap samples, print resulted intervals
bootsamples=1e4;
ci_bootstrap=bootci(bootsamples,{@mean,difference});
sprintf("The parametric mean 95percent confidence interval is [%4.2f %4.2f]\n Bootstrap mean 95percent confidence interval is [%4.2f %4.2f]",...
    ci_parametric(1),ci_parametric(2),ci_bootstrap(1),ci_bootstrap(2))
%By having a look at the two confidence intervals we can easily state that 14
%is not a number that could represent the time difference between the daily confirmed
%cases distribution and deaths distribution, these results though are
%generated from these 11 countries that were picked, if more countries were
%included , results could be a lot more different. The fact that
%our initial model fitted to our dataset surely has some errors made and
%these errors can never be ignored and therefore the maximum points difference of the
%curves is different from the real data set. Many negative differences appear and therefore a part of the confidence
%intervals lies in the negative values. Of course these negative
%differences troubled me since this was not the expecting incoming result , but
%since I chose not to change anything from the given dataset or add or
%delete anything from the dataset(except for NaN values and negative ones) 
%I proceeded with these results.
%These negative differences were taken into account as a "peculiarity" of the
%data set in conjunction with the errors introduced by the fitting curves.

% Countries chosen for the next exercises and their difference for their maximum cases
%minus maximum deaths day computed in this exercise:
%Serbia:13, The Netherlands:11, UK:1, Italy:-5, France:-8,Armenia: -7