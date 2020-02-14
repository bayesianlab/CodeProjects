function [] = writeVdToFile(filename,varianceDecomp, subset)
saveTostatespace = join(['~/GoogleDrive/statespace/',filename]);
varianceDecomp = 100.*varianceDecomp;
filevardec= fopen(saveTostatespace, 'w+');
subvd = varianceDecomp(subset,:);
world = subvd(:,2);
region =subvd(:,3);
country= subvd(:,3);
vard = subvd(:,1);
for j = 1:size(subvd,1)
    if world(j) < .1
        worldstr = num2str(world(j),  ['%.1e', 3]);
        eloc = strfind(worldstr, 'e');
        p=worldstr(eloc+1:end-1);
        exponent = num2str(str2double(convertCharsToStrings(p)));
        worldstr = join(['$', worldstr(1:eloc-1), ' \\times 10^{', exponent,'}$ &']);
    else
        worldstr = sprintf(' %.1f &', subvd(j,2));
    end
    if region(j) < .1
        regionstr = num2str(region(j),  ['%.1e', 3]);
        eloc = strfind(regionstr, 'e');
        p=regionstr(eloc+1:end-1);
        exponent = num2str(str2double(convertCharsToStrings(p)));
        regionstr = join([' $', regionstr(1:eloc-1), ' \\times 10^{', exponent,'}$&']);
    else
        regionstr = sprintf(' %.1f &', subvd(j,3));
    end
    if country(j) < .1
        countrystr = num2str(country(j),  ['%.1e', 3]);
        eloc = strfind(countrystr, 'e');
        p=countrystr(eloc+1:end-1);
        exponent = num2str(str2double(convertCharsToStrings(p)));
        countrystr = join([' $', countrystr(1:eloc-1), ' \\times 10^{', exponent,'}$&']);
    else
        countrystr = sprintf(' %.1f &', subvd(j,4));
    end
    if vard(j) < .1
        vardstr = num2str(vard(j),  ['%.1e', 3]);
        eloc = strfind(countrystr, 'e');
        p=vardstr(eloc+1:end-1);
        exponent = num2str(str2double(convertCharsToStrings(p)));
        vardstr = join([' $', vardstr(1:eloc-1), ' \\times 10^{', exponent,'}$&']);
    else
        vardstr = sprintf(' %.1f &', subvd(j,1));
    end
    fstr = join([worldstr, regionstr, countrystr, vardstr, '\n']);
    fprintf(filevardec, fstr);
end
fclose(filevardec');
end

