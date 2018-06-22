function variable_file = get_variable_file_path(sub_id, var_name)
% This function returns the complete file path based on a subject and
% variable.
[~, dir_dataset] = timevp_config_dataset_info();

variable_file = fullfile(dir_dataset, int2str(sub_id), sprintf('%s.csv', var_name));