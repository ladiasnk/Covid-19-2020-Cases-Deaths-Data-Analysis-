%Nikolaos Ladias
clear variables;
clear all;
clear figures;
clc;
%countries:{France,Germany,UK,SPain,Ireland,Italy,Austria,Belgium,Netherlands,Serbia}
%first wave dates for each country(+3 when accesing data from table due to first 3 columns)
%France 12/3-25/5
%Germany 10/3-13/6
%UK 1/3-5/8
%Spain 6/3-21/6
%Ireland 24/3-17/6
%Italy 22/2-13/7
%Austria 17/3-19/5
%Belgium 14/3-1/7
%Netherland 16/3-9/7
%Serbia 24/3-2/6
countries={'Germany', 'Italy', 'UK', 'Belgium', 'Serbia', 'Austria', 'Ireland', 'France', 'Spain', 'The Netherlands'};
data=readtable('Covid19Deaths.xlsx');
%days are number from 1 to 348 +3 including first 3 columns to acess data
%from initital table for each country, first index is the row of the table,
%the number which the country is found, second is the duration of the wave
%in numbered days
France=table2array(data(48,66:147));
Germany=table2array(data(52,73:168));
UK=table2array(data(147,64:221));
Spain=table2array(data(130,69:134));
Ireland=table2array(data(65,87:141));
Italy=table2array(data(67,56:198));
Austria=table2array(data(8,80:113));
Belgium=table2array(data(13,77:186));
Netherland=table2array(data(97,76:194));
Serbia=table2array(data(121,87:157));
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
   %initial beta values for fitnlm
   Y=U{1,i};
   %Exactly same way I did with cases where Spain had some negative values,
   %by looking visually those values in comparison to other numbers of cases 
   %I assumed that these values
   %were just meant to be positive and so I make sure every country has the
   %same treatment for its negative values since I noticed the same thing for 
   %every country I used that had some negative values and I replace them with 
   %their absolute value and it made sense in comparison to its neighboring
   %values. Same exact thing for deaths and same reason I replace them.
   Y(Y<0)=abs(Y(Y<0));
   %Need to not have any NaN values in any data set, so I remove them .
   Y=Y(~isnan(Y));
   X=1:1:length(Y);
   X=reshape(X,length(X),1);
   %best fitting model for daily deaths distribution was the Normal model
   dist=fitdist(X,'Nakagami','frequency',Y);
   yFitted=pdf(dist,X);
   yFitted=reshape(yFitted,length(yFitted),1);
   %an alternative way to scale data is to pass 'norm' equal to 1 as an
   %argument in our normalize function, this will ensure our data gets
   %normalized properly
   Y=normalize(Y,'norm',1);
   Y=reshape(Y,length(Y),1);
   %rmse computed and stored,(error=normalized original values-values gained from pdf)
   errors=Y-yFitted;
   rmse_array(i,1)=sqrt(1/(length(Y)-2)*sum(errors.^2) );
   %figure for each country for better visualization
   figure(i);
   bar(Y);
   hold on;
   plot(X, yFitted, 'LineWidth', 2);
   msg=sprintf('Bargraph for daily cases distribution for %s',countries{1,i});
   legend(msg,'Nakagami fitted distribution');
end
sorted_rmse=sort(rmse_array,'descend');

%rank countries from greatest fit to worst fit

sprintf('Ranked countries from best fit to worst fit according to normal model distribution\n one-->best fit,two-->second bets fit and so on')
    %print ranked countries from best fit to worst fit to console
for i=1:10
   sprintf('%d %s',i,countries{1,rmse_array==sorted_rmse(i,1)}) 
end