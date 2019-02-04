function [Fsubset] = subsetFt(Ft, InfoRow, Regions)
RegionIndex = InfoRow(1) + 1;
CountryIndex = 1 + Regions + InfoRow(2);
Fsubset = [Ft(1,:); Ft(RegionIndex,:); Ft(CountryIndex,:)];
end

