function data = get_variable_data(subject_id, variable_name)

if has_variable(subject_id, variable_name)
    data_filepath = get_variable_file_path(subject_id, variable_name);
    data = csv2stream(data_filepath);
else
    warning('Subject %d does not have variable %s.', subject_id, variable_name);
    data = [];
end