function [ log_diff_output_t,log_diff_cpi_t, t_bonds_t] = createData2( )
[t, cpi] = import_fred_data('cpi.csv', 2, 711);
[t, t_bonds] = import_fred_data('t_bonds.csv', 2, 756);
[time, output] = import_fred_data('INDPRO.csv', 2, 1167);
february1958 = 470;
end_date = length(output);


cpi = vertcat(zeros(456,1), cpi);
log_diff_cpi = vertcat(0, diff(log(cpi)));
t_bonds = vertcat(zeros(411,1), t_bonds);
log_diff_output = vertcat(0,diff(log(output)));
log_diff_output_t = log_diff_output(february1958 -12:...
    length(log_diff_output), 1);


log_diff_cpi_t = log_diff_cpi(february1958-12:length(log_diff_cpi),1);
t_bonds_t = t_bonds(february1958-12:length(cpi));

end

