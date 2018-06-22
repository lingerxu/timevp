function data_filepath = save_variable_data(subject_id, variable_name, data)

% data_filepath = '';

if isempty(data)
    error('Input data is empty. Cannot save empty data to csv files.');
%     return;
end

if has_variable(subject_id, variable_name)
    warning('Subject %d already save data file %s.csv. It will be replaced with the new file.', ...
        subject_id, variable_name);
end

data_filepath = get_variable_file_path(subject_id, variable_name);
write2csv(data, data_filepath);

