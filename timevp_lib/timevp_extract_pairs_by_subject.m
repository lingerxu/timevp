function [allpairs, events1_wo, events2_wo] = timevp_extract_pairs_by_subject(subject_list, variable1, variable2, timing_relation, dir_savefiles, mapping, args)

NUM_DEFAULT = 150;

if ~exist('mapping', 'var') || isempty(mapping)
    mapping = [(1:NUM_DEFAULT)' (1:NUM_DEFAULT)'];
end

if ~exist('args', 'var') || isempty(args)
    args = struct();
end

num_subs = length(subject_list);
allpairs = cell(num_subs, 1);
events1_wo = cell(num_subs, 1);
events2_wo = cell(num_subs, 1);

for sidx = 1:num_subs
    sub_id = subject_list(sidx);
    
    if has_variable(sub_id, variable1)
        file_var1 = get_variable_file_path(sub_id, variable1);
    else
        warning('Subject %d does not have variable %s.', sub_id, variable1);
        continue
    end
    
    if has_variable(sub_id, variable2)
        file_var2 = get_variable_file_path(sub_id, variable2);
    else
        warning('Subject %d does not have variable %s.', sub_id, variable2);
        continue
    end
    
    file_savename = fullfile(dir_savefiles, sprintf('extract_pairs_%s_%s_%d.csv',variable1, variable2, sub_id));
    
    [pairs_sub, events1_sub, events2_sub] = timevp_extract_pairs(file_var1, file_var2, timing_relation, file_savename, mapping, args);
    
    allpairs{sidx} = pairs_sub;
    events1_wo{sidx} = events1_sub;
    events2_wo{sidx} = events2_sub;
end