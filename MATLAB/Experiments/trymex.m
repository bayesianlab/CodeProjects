clear;
clc;


copyfile(fullfile('/Users/dillonflannery-valadez/Google Drive', 'CodeProjects', ...
    'CProjects', 'Stat225', 'src', 'statsource.cpp'), '.', 'f')


mex -v statsource.cpp


