function [profile_data] = timevp_construct_temporal_profile(input)
% This function generates temporal profile of a group of continue variables
% or one cstream profile chunked by one cevent variable.
%
% For detailed user guide one this function, please go to demo script at:
% 
% 
% Last update by Linger, txu@indiana.edu on 07/21/2016

float_tolerance = 1e-12;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub_list = input.sub_list;

if ~(isfield(input, 'whence') && isfield(input, 'interval'))
    error(['Error. This functions only works ''whence'' and ''interval'' are both specified. ' ...
        'For example, one wants to generate gaze profile 10 seconds before to the onset of ' ...
        'naming instances. In this case, whence is ''start'', interval is [-10 0].']);
else
    whence = input.whence;
    interval = input.interval;
end

if ~isfield(input, 'event_category')
    error(['When data are regrouped by events, the field ' ...
        'EVENT_CATEGORY must be specified.']);
else
    event_category = input.event_category;
end
if ~isfield(input, 'var_category')
    error(['Under all situations, the field ' ...
        'VAR_CATEGORY must be specified.']);
else
    var_category = input.var_category;
end

if isfield(input, 'sample_rate')
    sample_rate = input.sample_rate;
else
    sample_rate = timevp_config_dataset_info();
end

% if strcmp(whence, 'start')
%     ref_column = 1;
%     str_align = 'onset';
% elseif strcmp(whence, 'end')
%     ref_column = 2;
%     str_align = 'offset';
% end

segment_event = input.segment_event;
var_name = input.var_name;

% check if variable exists for all subjects
x_has_var_event = arrayfun( ...
    @(sub_id) ...
    has_variable(sub_id, segment_event), ...
    sub_list, ...
    'UniformOutput', 0);
x_has_var_event = vertcat(x_has_var_event{:});

if sum(~x_has_var_event) > 0
    missvar_sub_list = num2str(sub_list(~x_has_var_event)');
    fprintf('Variable %s does not exist for subject(s) %s\n', segment_event, missvar_sub_list);
end
mask_has_variable = x_has_var_event;

groupid_matrix = input.groupid_matrix;
groupid_list = unique(groupid_matrix);
num_groupids = length(groupid_list);

if iscell(input.var_name)
    example_var_name = var_name{1};
    is_var_cell = true;
    num_vars = length(var_name);
    
    if size(groupid_matrix, 1) ~= num_vars
        error(['In ''groupid_matrix'', each row corresponding to a cstream ROI value or the order of cont type ' ...
            'variable, and each column corresponding to a event value. So, if you input a cell list of ' ...
            'cont variables in the grouping variable list, the number and order of the variables ' ...
            'should match with the rows in groupid_matrix.']);
    end
    
    for vidx = 1:num_vars
        x_var_one = arrayfun( ...
            @(sub_id) ...
            has_variable(sub_id, var_name{vidx}), ...
            sub_list, ...
            'UniformOutput', 0);
        x_var_one = vertcat(x_var_one{:});

        if sum(~x_var_one) > 0
            missvar_sub_list = num2str(sub_list(~x_var_one)');
            fprintf('Variable %s does not exist for subject(s) %s\n', var_name{vidx}, missvar_sub_list);
        end
        mask_has_variable = mask_has_variable & x_var_one;
    end
else
    example_var_name = var_name;
    is_var_cell = false; % meaning the input variable only has one cstream
    num_vars = 1;

    x_var_one = arrayfun( ...
        @(sub_id) ...
        has_variable(sub_id, var_name), ...
        sub_list, ...
        'UniformOutput', 0);
    x_var_one = vertcat(x_var_one{:});

    if sum(~x_var_one) > 0
        missvar_sub_list = num2str(sub_list(~x_var_one)');
        fprintf('Variable %s does not exist for subject(s) %s\n', var_name, missvar_sub_list);
    end
    mask_has_variable = mask_has_variable & x_var_one;
end

if size(groupid_matrix, 1) ~= length(var_category)
    error(['In ''groupid_matrix'', each row corresponding to a cstream ROI value or the order of cont type ' ...
        'variables, and each column corresponding to a event value. So, the number of values in ' ...
        '''var_category'' should match with the number of rows in groupid_matrix.']);
end

if size(groupid_matrix, 2) ~= length(event_category)
    error(['In ''groupid_matrix'', each row corresponding to a cstream value/variable, and ' ...
        'each column corresponding to a event value. So, the number of values in ' ...
        '''event_category'' should match with the number of columns in groupid_matrix.']);
end

sub_list = sub_list(mask_has_variable);

% Initialize result
result_chunks = cell(length(sub_list), num_groupids);
result_sub_list = cell(length(sub_list), 1);
result_ranges = cell(length(sub_list), 1);
result_events = cell(length(sub_list), 1);
result_event_index = cell(length(sub_list), 1);
result_probs_mean = cell(length(sub_list), 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for sidx = 1:length(sub_list)
    sub_id = sub_list(sidx);
    
    if is_var_cell
        var_data = cell(1, num_vars);
        
        for vidx = 1:num_vars
            data_one = get_variable_data(sub_id, var_name{vidx});
            if size(data_one, 2) == 3
                warning('Variable %s is in event data format, convert to streams.', var_name{vidx});
                data_one = event2stream(data_one);
            end
            
            var_data{vidx} = data_one;
        end
    else
        var_data = get_variable_data(sub_id, var_name);
        warning('Variable %s is in event data format, convert to streams.', var_name);
        var_data = event2stream(var_data);
    end

    time_base = interval(1):sample_rate:(interval(2)-+0.0001);
    length_profile = length(time_base);
    duration_profile = interval(2) - interval(1);
    time_base_ts = 0:sample_rate:(duration_profile-0.0001);

    event_data = get_data_by_subject(sub_id, segment_event);
    num_events = size(event_data, 1);
    
    if size(event_data, 2) == 2
        warning('Segment event variable %s is in stream data format, convert to events.', segment_event);
        event_data = stream2event(event_data, sample_rate);
    end

    if isfield(input, 'event_min_dur')
        event_dur = event_data(:,2) - event_data(:,1); 
        x_dur_mask = event_dur >= input.event_min_dur;
        event_data = event_data(x_dur_mask, :);
    end

    if isfield(input, 'event_max_dur')
        event_dur = event_data(:,2) - event_data(:,1); 
        x_dur_mask = event_dur <= input.event_max_dur;
        event_data = event_data(x_dur_mask, :);
    end

    if isempty(event_data)
        fprintf('Subject %d has zero instances of %s that met criteria.\n', sub_id, segment_event);
        continue
    end

    % After retrieving event data, start getting cont/cstream
    % variables
    result_sub_list{sidx, 1} = repmat(sub_id, num_events, 1);
    result_events{sidx, 1} = event_data;
    result_event_index{sidx, 1} = (1:num_events)'; 
    probs_mean_sub = nan(num_events, num_groupids);

    temporal_ranges = event_relative_intervals(...
        event_data, input.whence, input.interval);

    if isfield(input, 'within_ranges') && ~input.within_ranges
        temporal_ranges = get_event_opposite(sub_id, event_data, trials_one);
    end

    result_ranges{sidx, 1} = temporal_ranges;

    chunks_profile_sub = cell(1, num_groupids);
    for coidx = 1:num_groupids
        chunks_profile_sub{coidx} = nan(num_events, length_profile);
    end

    % when user input a list of continue variables
    if is_var_cell
        % chunks_var_origin stores the variable extracted from the dataset
        chunks_var_origin = cell(num_events, num_vars);
        mat_var_profile = nan(num_events, length_profile, num_vars);
        cont_sum_sub = zeros(num_events, length_profile, num_groupids);
        cont_count_sub = zeros(num_events, length_profile, num_groupids);
        
        % fetch and format continue variable data
        for vidx = 1:num_vars
            chunks_var_one  = extract_ranges(var_data{vidx}, ...
                str_var_type, {temporal_ranges});
            mat_profile_one = nan(num_events, length_profile);
            
            for cnidx = 1:num_events
                range_one = temporal_ranges(cnidx, :);

                chunks_one_new = chunks_var_one{cnidx};
                chunks_one_new(:, 1) = chunks_one_new(:, 1) - range_one(1);
                length_one = size(chunks_one_new, 1);

                if length_one < length_profile
                    chunk_ts = timeseries(chunks_one_new(:, 2:end), chunks_one_new(:, 1));
                    chunk_ts = resample(chunk_ts, time_base_ts, 'zoh');
                    chunks_one_new = horzcat(get(chunk_ts, 'Time'), get(chunk_ts, 'Data'));
                end

                chunks_one_new(isnan(chunks_one_new(:,2)),2) = 0;
                mat_profile_one(cnidx, :) = chunks_one_new(:, 2)';
            end
            
            mat_var_profile(:, :, vidx) = mat_profile_one;
        end
        
        for eventidx = 1 : length(event_category)
            event_values = event_category(eventidx);
            label_column = groupid_matrix(:, eventidx);
            label_column_list = unique(label_column);

            mask_cvalues = ismember(event_data(:, 3), event_values);
%             chunks_var_by_cvalue = chunks_var_origin(mask_cvalues);
%             chunks_ranges = temporal_ranges(mask_cvalues);
%             num_events_value = sum(mask_cvalues);
            
            for lidx = 1:length(label_column_list)
                label_one = label_column_list(lidx);
                target_categories = var_category(label_column == label_one);
                
                tmp_profile = cont_sum_sub(mask_cvalues, :, label_one);
                tmp_count = cont_count_sub(mask_cvalues, :, label_one);
                cont_sum_sub(mask_cvalues, :, label_one) = ...
                    cont_sum_sub(mask_cvalues, :, label_one) + ...
                    sum(mat_var_profile(mask_cvalues, :, target_categories), 3);
                cont_count_sub(mask_cvalues, :, label_one) = ...
                    cont_count_sub(mask_cvalues, :, label_one) + ...
                    sum(mat_var_profile(mask_cvalues, :, target_categories)>0, 3);
            end
        end % end of going through all events
        
        for gidx = 1:num_groupids
            label_one = groupid_list(gidx);
            tmp_count = cont_count_sub(:, :, gidx);
            probs_mean_sub(:, gidx) = sum(cont_sum_sub(:, :, gidx), 2) ./ sum(tmp_count, 2);
            tmp_count(tmp_count < 1) = 1;
            chunks_profile_sub{gidx} = cont_sum_sub(:, :, gidx) ./ tmp_count;
        end
    % when user input is not a cell of variables
    else
        % chunks_var_origin stores the variable extracted from the dataset
        chunks_var_origin = extract_ranges(var_data, {temporal_ranges});
        
        % chunks_var_mat stores the variables that were reassigned
        chunks_var_mat = nan(num_events, length_profile);
        chunks_check_mat = nan(num_events, length_profile);

        for eventidx = 1 : length(event_category)
            event_values = event_category(eventidx);
            label_column = groupid_matrix(:, eventidx);
            label_column_list = unique(label_column);

            mask_cvalues = ismember(event_data(:, 3), event_values);
            chunks_var_by_cvalue = chunks_var_origin(mask_cvalues);
            chunks_ranges = temporal_ranges(mask_cvalues);
            num_events_value = sum(mask_cvalues);

            mat_var_profile = nan(num_events_value, length_profile);

            for cnidx = 1:size(chunks_ranges, 1)
                range_one = chunks_ranges(cnidx, :);

                chunks_one_new = chunks_var_by_cvalue{cnidx};
                chunks_one_new(:, 1) = chunks_one_new(:, 1) - range_one(1);
                length_one = size(chunks_one_new, 1);

                if length_one < length_profile
                    chunk_ts = timeseries(chunks_one_new(:, 2:end), chunks_one_new(:, 1));
                    chunk_ts = resample(chunk_ts, time_base_ts, 'zoh');
                    chunks_one_new = horzcat(get(chunk_ts, 'Time'), get(chunk_ts, 'Data'));
                end

                mat_var_profile(cnidx, :) = chunks_one_new(:, 2)';
            end

            mat_origin_profile = mat_var_profile;
            for lidx = 1:length(label_column_list)
                label_one = label_column_list(lidx);
                target_categories = var_category(label_column == label_one);

                mask_reassign = ismember(mat_origin_profile, target_categories);
                mat_var_profile(mask_reassign) = label_one;
            end

            chunks_check_mat(mask_cvalues, :) = mat_origin_profile;
            chunks_var_mat(mask_cvalues, :) = mat_var_profile;
        end % end of going through event categorical values

        for gidx = 1 : num_groupids
            label_target = groupid_list(gidx);
            label_other = setdiff(groupid_list, label_target);

            % Each cell contains the matrix that holds data for one group label
            tmp_chunk = chunks_profile_sub{gidx};

            mask_group = ismember(chunks_var_mat, label_target);
            tmp_chunk(mask_group) = 1;
            mask_other = ismember(chunks_var_mat, label_other);
            tmp_chunk(mask_other) = 0;
            mask_zeros = chunks_var_mat < 1;
            tmp_chunk(mask_zeros) = 0;
            chunks_profile_sub{gidx} = tmp_chunk;

            num_valid_data = sum(~isnan(tmp_chunk), 2);
            num_matches = sum(mask_group, 2);
            probs_mean_sub(:, gidx) = num_matches ./ num_valid_data;
        end
    end
    
    result_chunks(sidx, :) = chunks_profile_sub;
    result_probs_mean{sidx, :} = probs_mean_sub;
end % end of sidx
 
% result_chunks = vertcat(result_chunks{:});
result_probs_mean = vertcat(result_probs_mean{:});

% subID	expID	onset	offset	category	instanceID
profile_data.sub_list = vertcat(result_sub_list{:});
profile_data.events = vertcat(result_events{:});
profile_data.event_instanceid = vertcat(result_event_index{:});
profile_data.probs_mean_per_instance = result_probs_mean;

if isfield(input, 'groupid_label')
    profile_data.groupid_label = input.groupid_label;
else
    profile_data.groupid_label = {'target', 'non-target', 'other'};
    profile_data.groupid_label = profile_data.groupid_label(groupid_list);
end
profile_data.group_list = groupid_list';
profile_data_mat = cell(1, num_groupids);
for gidx = 1:num_groupids
    profile_data_mat{gidx} = vertcat(result_chunks{:, gidx});
end
profile_data.profile_data_mat = profile_data_mat;
profile_data.sample_rate = sample_rate;
profile_data.time_base = time_base;
profile_data.segment_event = segment_event;
profile_data.variable_name = var_name;
