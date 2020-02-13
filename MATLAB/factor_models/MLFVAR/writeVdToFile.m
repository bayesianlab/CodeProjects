function [] = writeVdToFile(filename,varianceDecomp, subset)
saveTostatespace = join(['~/GoogleDrive/statespace/',filename]);
varianceDecomp = 100.*varianceDecomp;
filevardec= fopen(saveTostatespace, 'w+');
subsetvd =  round(varianceDecomp(subset,:),1);
world = varianceDecomp(:,2);
for j = 1:size(subsetvd,1)
    worldstr = num2str(world(j),  ['%.1e', 3]);
    eloc = strfind(worldstr, 'e');
    p=worldstr(eloc+1:end-1);
    exponent = num2str(str2double(convertCharsToStrings(p)));
    worldstr = join(['$', worldstr(1:eloc-1), ' \\times 10^{', exponent,'}$&']);
    
    if floor(subsetvd(j,3)) < 10
        part1 = sprintf(' %.1f &', subsetvd(j,3));
    else
        part1 = sprintf('%.1f &', subsetvd(j,3));
    end
    if floor(subsetvd(j,4)) < 10
        part2 = sprintf(' %.1f &', subsetvd(j,4));
    else
        part2 = sprintf('%.1f &', subsetvd(j,4));
    end
    if floor(subsetvd(j,1)) < 10
        part3 = sprintf(' %.1f &', subsetvd(j,1));
    else
        part3 = sprintf('%.1f &', subsetvd(j,1));
    end    
    fstr = join([worldstr, join([part1, part2, part3]), '\n']);
    fprintf(filevardec, fstr);
end
fclose(filevardec');
end

