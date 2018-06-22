function timevp_extract_measures(subject_list, variable_list, segment_event, save_filename, args)

args.segment_event = segment_event;

% fetch data
num_subs = length(subject_list);
num_vars = length(variable_list);

if isfield(args, 'sample_rate')
    sample_rate = args.sample_rate;
else
    [~, sample_rate] = timevp_config_dataset_info();
end

if isfield(args, 'groupid_matrix')
    is_regroup = true;
    if ~isfield(args, 'var_category') || ~isfield(args, 'event_category')
        error(['In order to regroup varaible by event categories, users need to specify' ...
            'VAR_CATEGORY and EVENT_CATEGORY.']);
    end
else
    is_regroup = false;
end

% header_row1 = {'segment event:', '', };
% subject ID, instance ID, onset, offset, category
header_row1 = cell(1, 5);
header_row1{1} = 'segment event:';
header_row1{2} = segment_event;
header_row2 = cell(1, 5);
header_events = {'subject ID', 'instance ID', 'onset', 'offset', 'category value'};
header_variables = {};

results_all_measures = [];

data_all = cell(num_subs, num_vars);
ranges_all = cell(num_subs, num_vars);
categories_var = cell(1, num_vars);
num_cols_data = nan(1, num_vars);

for vidx = 1:num_vars
    var_name = variable_list{vidx};
    
    if isfield(args, 'var_category')
        args.categories = args.var_category;
    end
    [var_data, extra_info] = get_data_by_subject(subject_list, var_name, args);
    
    if is_regroup
        var_data_regroup = cell(num_subs, 1);
        groupid_list = unique(args.groupid_matrix);
        for sidx = 1:num_subs
            var_data_regroup{sidx} = regroup_data(var_data{sidx}, args.var_category, ...
                extra_info.ranges{sidx}, args.event_category, args.groupid_matrix);
        end
        data_all(:, vidx) = var_data_regroup;
        ranges_all(:, vidx) = extra_info.ranges;
        categories_var{1, vidx} = groupid_list;
        num_cols_data(1, vidx) = extra_info.num_cols_data;
    else
        data_all(:, vidx) = var_data;
        ranges_all(:, vidx) = extra_info.ranges;
        categories_var{1, vidx} = extra_info.categories;
        num_cols_data(1, vidx) = extra_info.num_cols_data;
    end
end

args.sample_rate = sample_rate;

for sidx = 1:num_subs
    sub_id = subject_list(sidx);
    ranges_sub = ranges_all{sidx, 1};
    num_events = size(ranges_sub, 1);
    results_event = [repmat(sub_id, num_events, 1) (1:num_events)' ranges_sub];
    
    if isempty(ranges_sub)
        continue
    end
    results_variables = [];
    
    for vidx = 1:num_vars
        var_name = variable_list{vidx};
        var_sub = data_all{sidx, vidx};
        args.categories = categories_var{1, vidx};
        args.individual_ranges = ranges_sub;
        
        num_categories = length(args.categories);

        if num_cols_data(1, vidx) == 2
            if isempty(var_sub)
                results_variables = [results_variables nan(num_events, num_categories)];
            else
                results_one = stream_cal_stats(var_sub, args);
                results_variables = [results_variables results_one.individual_prop_by_cat];
            end

            % Construct csv header information, only needed once
            if sidx == 1
                if is_regroup && isfield(args, 'group_label')
                    header_one = args.group_label;
                else
                    header_one = arrayfun(@(x) ['cat-' num2str(x)], ...
                        results_one.categories, 'UniformOutput', false);
                end
                header_row2 = [header_row2 {'proportion_by_category'} cell(1, num_categories-1)];
            end
        elseif num_cols_data(1, vidx) == 3
            if isempty(var_sub)
                results_variables = [results_variables nan(num_events, num_categories*3)];
            else
                results_one = event_cal_stats(var_sub, args);
                results_variables = [results_variables results_one.individual_prop_by_cat ...
                    results_one.individual_mean_dur_by_cat, results_one.individual_number_by_cat];
            end

            % Construct csv header information, only needed once
            if sidx == 1
                if is_regroup && isfield(args, 'group_label')
                    header_one = args.group_label;
                else
                    header_one = arrayfun(@(x) ['cat-' num2str(x)], ...
                        results_one.categories, 'UniformOutput', false);
                end
                header_one = repmat(header_one, 1, 3);
                header_row2 = [header_row2 {'proportion_by_category'} cell(1, num_categories-1)...
                    {'mean_duration_by_category'} cell(1, num_categories-1) ...
                    {'number_of_events_by_category'} cell(1, num_categories-1)];
            end
        else
            error('Invalid data type with %d columns.', num_cols_data(1, vidx));
        end

        if sidx == 1
            header_variables = [header_variables header_one];
            header_row1 = [header_row1 {var_name} cell(1, length(header_one)-1)];
        end
    end
    
    results_all_measures = [results_all_measures; [results_event results_variables]];
end % end of sidx

header_info = [header_row1; header_row2; cell(1, length(header_row1)); ...
    [header_events header_variables]];
csv_measures = num2cell(results_all_measures);

cell2csv(save_filename, [header_info; csv_measures]);
fprintf('Result file saved to: %s\n', save_filename);
