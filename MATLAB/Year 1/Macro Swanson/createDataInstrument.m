function [ X, time  ] = createDataInstrument(  )
[t, cpi] = import_fred_data('cpi.csv', 2, 711);
[t, t_bonds] = import_fred_data('t_bonds.csv', 2, 756);
[time, output] = import_fred_data('INDPRO.csv', 2, 1167);
january1983 = 781-12;
end_date = length(output);


cpi = vertcat(zeros(456,1), cpi);
log_diff_cpi = vertcat(0, diff(log(cpi)));
t_bonds = vertcat(zeros(411,1), t_bonds);

X = [  log(output(january1983:end_date,1)), log_diff_cpi(january1983:end_date, 1),...
    t_bonds(january1983:end_date,1)];


end

