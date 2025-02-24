%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /Users/dillonflannery-valadez/Google Drive/MATLAB/Econometrics/BrownstoneHW1_Q3/Data_PS1_S15.xlsx
%    Worksheet: Sheet1
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2016/04/12 17:56:51

%% Import the data
data = xlsread('/Users/dillonflannery-valadez/Google Drive/MATLAB/Econometrics/BrownstoneHW1_Q3/Data_PS1_S15.xlsx','Sheet1');

%% Allocate imported array to column variable names
y = data(:,1);
const = data(:,2);
x_1 = data(:,3);
x_2 = data(:,4);

%% Clear temporary variables
clearvars data raw;