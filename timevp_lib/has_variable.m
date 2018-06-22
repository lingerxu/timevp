function has_it = has_variable(subject_id, var_name)
%Returns true if the variable file exists in that subj's dir.
%   has_variable(SUBJECT_ID, VARIABLE_NAME)
%
%   Searches the data/subject_id subdirectory of the subject data associated with
%   the given numerical subject ID, and sees if a csv or mat file containing
%   the given variable exists.  If so, returns 1, if not, returns 0.

variable_file = get_variable_file_path(subject_id, var_name);
has_it = exist(variable_file, 'file') == 2;

end
