function [var_data_regroup] = regroup_data(var_data, var_category, events, event_category, groupid_matrix)

groupid_matrix_list = unique(groupid_matrix);
% 
% if isfield(args, 'sample_rate')
%     sample_rate = args.sample_rate;
% else
%     [~, sample_rate] = timevp_config_dataset_info();
% end

% results_all_measures = [];

% sub_id = subject_list(1);
% vidx = 1;
% var_name = variable_list{vidx};
% [var_data, extra_info] = get_data_by_subject(sub_id, var_name, args);

% events = extra_info.ranges;
% extracted_var_len = extra_info.num_cols_data;

if isempty(var_data) || isempty(events)
    var_data_regroup = [];
    warning('Empty data input.')
    return
end

ROI_OFFSET = 1000;

groupid_list = unique(groupid_matrix);
num_groupids = length(groupid_list);
num_events = size(events, 1);
var_data_regroup = cell(num_events, 1);

num_var = length(var_data);

if num_var ~= num_events
    error('The length of VAR_DATA should be the same as the length of EVENTS.');
end

var_length = nan(num_var, 1);
for vidx = 1:num_var
    var_length(vidx) = size(var_data{vidx}, 2);
end

var_length_unique = setdiff(unique(var_length), 0);
if length(var_length_unique) > 1
    warning(['Not all variables are in the same data type. The function will convert' ...
        ' all event type data in variable list to stream type data.']);
    for vidx = 1:num_var
        data_one = var_data{vidx};
        if isempty(data_one)
            continue
        end
        if var_length(vidx) == 3
            var_data{vidx} = event2stream(var_data{vidx});
        elseif var_length(vidx) ~= 2
            error('Invalid input. Data type can only be stream [timestamp value] or events [onset offset value].');
        end
    end
else
    extracted_var_len = var_length_unique;
end

if size(groupid_matrix, 1) ~= length(var_category)
    error(['In ''groupid_matrix'', each row corresponding to a cstream ROI value or the order of cont type ' ...
        'variables, and each column corresponding to a cevent value. So, the number of values in ' ...
        '''var_category'' should match with the number of rows in groupid_matrix.']);
end

if size(groupid_matrix, 2) ~= length(event_category)
    error(['In ''groupid_matrix'', each row corresponding to a cstream value/variable, and ' ...
        'each column corresponding to a cevent value. So, the number of values in ' ...
        '''event_category'' should match with the number of columns in groupid_matrix.']);
end

mask_temp = false(num_events, 1);

for ecidx = 1 : length(event_category)
    categories_one = event_category(ecidx);
    
    mask_events = ismember(events(:,3), categories_one);
    mask_temp = mask_temp | mask_events;
    events_one = events(mask_events, :);
    chunks_one = var_data(mask_events, :);

    label_column = groupid_matrix(:, ecidx);
    label_column_list = unique(label_column);

    for lidx = 1:length(label_column_list)
        label_one = label_column_list(lidx);
%                 label_one_idx = find(groupid_matrix_list == label_one);
        target_categories = var_category(label_column == label_one);

        if extracted_var_len == 2
            chunks_one = cellfun( ...
                @(chunk_one) ...
                cstream_reassign_categories(chunk_one, {target_categories}, {label_one+ROI_OFFSET}), ...
                chunks_one, ...
                'UniformOutput', 0);
        elseif extracted_var_len == 3
            chunks_one = cellfun( ...
                @(chunk_one) ...
                cevent_reassign_categories(chunk_one, {target_categories}, {label_one+ROI_OFFSET}), ...
                chunks_one, ...
                'UniformOutput', 0);
        else
            error('Invalid input. Data type can only be stream [timestamp value] or events [onset offset value].');
        end
        var_data_regroup(mask_events, :) = chunks_one; 
    end
end

% reassign the roi values back to roi values
if extracted_var_len == 2
    chunks_new = var_data_regroup;
    for cnidx = 1:length(chunks_new)
        chunk_one_new = chunks_new{cnidx};
        if isempty(chunk_one_new)
            continue
        end
        for lmlidx = 1:length(groupid_matrix_list)
            label_one = groupid_matrix_list(lmlidx);
            chunk_one_new = ...
                cstream_reassign_categories(chunk_one_new, {label_one+ROI_OFFSET}, {label_one});
        end

        [Y, I] = sort(chunk_one_new(:,1));
        chunk_one_new = chunk_one_new(I,:);
        var_data_regroup{cnidx} = chunk_one_new;
    end
elseif extracted_var_len == 3
    chunks_new = var_data_regroup;
    for cnidx = 1:length(chunks_new)
        chunk_one_new = chunks_new{cnidx};
        if isempty(chunk_one_new)
            continue
        end
        for lmlidx = 1:length(groupid_matrix_list)
            label_one = groupid_matrix_list(lmlidx);
            chunk_one_new = ...
                cevent_reassign_categories(chunk_one_new, {label_one+ROI_OFFSET}, {label_one});
        end
        [Y, I] = sort(chunk_one_new(:,1));
        chunk_one_new = chunk_one_new(I,:);
        var_data_regroup{cnidx} = chunk_one_new;
    end
else
    error('Invalid input: VAR_NAME. Please see example page.');
end

% final check if all ROIs are re-assigned
var_data_cat = vertcat(var_data_regroup{:});
all_categories = unique(var_data_cat(:,end));
all_categories = setdiff(all_categories, 0);
if ~isequal(all_categories, groupid_list)
    all_categories
    groupid_list
    error('Not all category values are reassigned during regrouping progress.');
end