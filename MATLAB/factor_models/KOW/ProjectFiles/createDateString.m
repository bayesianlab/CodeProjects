function [filename] = createDateString(f)
A=datestr(datetime('now'));
A= replace(A, ' ', '_');
A = replace(A,'-', '_');
A = replace(A,':', '_');
filename = strcat(f, A);
end

