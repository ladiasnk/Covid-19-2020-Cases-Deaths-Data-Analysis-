%Nikolaos Ladias
%clear variables,figures and make sure workspace works normally
clear variables;
clear all;
clear figures;
clc;
workspace;
%countries:{France,Germany,UK,SPain,Ireland,Italy,Austria,Belgium,Netherlands,Serbia}
%first wave dates for each country(+3 when accesing data from table due to first 3 columns)
%The criteria for the definitions of the first wave dates and its duration
%for each country are:
%                1)first rise of daily confirmed cases-deaths=begining
%                2)firt fall of dail confirmed cases-deaths=end
%France 12/3-25/5
%Germany 10/3-13/6
%UK 1/3-1/8
%Spain 1/3-10/5
%Ireland 4/3-17/6
%Italy 22/2-20/6
%Austria 28/2-10/5
%Belgium 5/3-17/6
%Netherland 1/3-9/7
%Serbia 12/3-2/6
countries={'Germany', 'Italy', 'UK', 'Belgium', 'Serbia', 'Austria', 'Ireland', 'France', 'Spain', 'The Netherlands'};
data=readtable('Covid19Confirmed.xlsx');
%days are number from 1 to 348 +3 including first 3 columns to acess data
%from initital table for each country, first index is the row of the table,
%the number which the country is found, second is the duration of the wave
%in numbered days
France=table2array(data(48,66:147));
Germany=table2array(data(52,73:168));
UK=table2array(data(147,64:217));
Spain=table2array(data(130,64:134));
Ireland=table2array(data(65,67:172));
Italy=table2array(data(67,56:175));
Austria=table2array(data(8,62:134));
Belgium=table2array(data(13,68:172));
Netherland=table2array(data(97,64:194));
Serbia=table2array(data(121,75:157));
%create the cell array that holds in every data gained for every country
%the cell array can contain different sized arrays of type double in its
%indexes and that is the reason it is used
U{1}=Germany;
U{2}=Italy;
U{3}=UK;
U{4}=Belgium;
U{5}=Serbia;
U{6}=Austria;
U{7}=Ireland;
U{8}=France;
U{9}=Spain;
U{10}=Netherland;
rmse_array=zeros(10,1);
for i=1:10
   %Y is the data for daily deaths distribution, according to each country
   Y=U{1,i};
   Y=reshape(Y,length(Y),1);
   %Spain had some negative values, by looking visually those values
   %in comparison to other numbers of cases I assumed that these values
   %were just meant to be positive and so I make sure every country has the
   %same treatment for its negative values since I noticed the same thing for 
   %every country I used that had some negative values and I replace them with 
   %their absolute value and it made sense in comparison to its neighboring values.
   Y(Y<0)=abs(Y(Y<0));
   %Need to not have any NaN values in any data set, so I remove them .
   Y=Y(~isnan(Y));
   X=1:1:length(Y);
   X=reshape(X,length(X),1);
   %best fit was Nakagami model for confirmed cases distribution
   dist=fitdist(X,'Nakagami','frequency',Y);
   yFitted=pdf(dist,X);
   yFitted=reshape(yFitted,length(yFitted),1);
   %an alternative way to scale data is to pass 'norm' equal to 1 as an
   %argument in our normalize function, this will ensure our data gets
   %normalized properly
   Y=normalize(Y,'norm',1);
   %rmse computed and stored,(error=normalized original values-values gained from pdf)
   errors=Y-yFitted;
   rmse_array(i,1)=sqrt(1/(length(Y)-2)*sum(errors.^2) );
   %figure for each country for better visualization
   figure(i);
   bar(Y);
   hold on;
   plot(X, yFitted, 'LineWidth', 2);
   msg=sprintf("Bargraph for daily cases distribution for %s",countries{1,i});
   legend(msg,"Nakagami fitted distribution");
end

sorted_errors=sort(rmse_array,'descend');

%rank countries from greatest fit to worst fit

sprintf("Ranked countries from best fit to worst fit according to Nakagami  model distribution\n one-->best fit,two-->second best fit and so on")
    
%rank countries from greatest fit to worst fit

for i=1:10
   sprintf('%d %s',i,countries{1,rmse_array==sorted_errors(i,1)}) 
end
%On the figures generated,all fitting curves along with their corresponding
%bargraphs are plotted normalized using the normalize function to fit the data 
%gained with its corresponding pdf.