function [  ] = hello_world(  )
file = fopen('testfile.txt', 'w')
fprintf(file, 'Hello World!!!!!!!!\n')
fclose('testfile.txt')
end

