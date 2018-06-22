function results = stream_cal_stats(chunks, args)
%STREAM_CAL_STATS Report various stypes of statistics of stream type data 
%chunks according to user args.
% 
% For examples and usage, go to: 
% demo_timevp_compute_statistics.m

% check fileds in 'args'
if ~exist('args', 'var')
    % this line of code is just to prevent from generating errors when
    % script checks whether a certain field exists.
    args.none_filed = 'No information here';
end

is_data_empty = check_data_empty(chunks);
if is_data_empty
    warning('Input data is empty. The function will exist now.')
    return;
%     data = get_test_data();
end

if isfield(args, 'subject_list')
    results.subject_list = args.subject_list;
end

if isfield(args, 'sample_rate')
    sample_rate = args.sample_rate;
else
    sample_rate = timevp_config_dataset_info();
end

cat_chunks = cat(1,chunks{:});
% max_category = nanmax(cat_chunks(:,2));

if isfield(args, 'categories')
    categories = args.categories;
    categories = categories(~isnan(categories));
    results.categories = categories;
else
    categories = unique(cat_chunks(:,2))';
    categories = categories(~isnan(categories));
    if isfield(args, 'nodata_marker')
        categories = categories(~ismember(categories, args.nodata_marker));
    end
    results.categories = categories;
end

%% calculate statistics
% proportion
x_prop_total = cat_chunks(:,2) > 0;
results.prop = nansum(x_prop_total)/length(x_prop_total);

% proportions for each category
res_proportions = zeros(1, length(categories));
for cidx = 1:length(categories)
    x_prop_one = (cat_chunks(:,2) <= (categories(cidx)+eps)) & ...
        (cat_chunks(:,2) >= (categories(cidx)-eps));

    res_proportions(cidx) = sum(x_prop_one)/length(x_prop_one);
end
results.prop_by_cat = res_proportions/nansum(res_proportions);

% proportions for each individual chunk
res_individual_prop_by_cat = zeros(length(chunks), length(categories));
results.individual_prop = zeros(length(chunks), 1);
for i = 1: length(chunks)
    chunk = chunks{i};
    if isempty(chunk)
        res_individual_prop_by_cat(i, :) = NaN;
    else
        for cidx = 1:length(categories)
            x_prop_one = (chunk(:,2) <= (categories(cidx)+eps)) & ...
                (chunk(:,2) >= (categories(cidx)-eps));            
            res_individual_prop_by_cat(i, cidx) = ...
                sum(x_prop_one)/length(x_prop_one);
        end
    end
    res_individual_prop_by_cat(i,:) = res_individual_prop_by_cat(i,:)/ ...
        nansum(res_individual_prop_by_cat(i,:));

    if ~isempty(chunk)
        x_prop_total = chunk(:,2) > 0;
        results.individual_prop(i, 1) = nansum(x_prop_total)/length(x_prop_total);
    else
        results.individual_prop(i, 1) = NaN;
    end
end
results.individual_prop_by_cat = res_individual_prop_by_cat;

is_cal_temporal = false;
if is_cal_temporal
    % calculate temporal profile
    offset = 0;
    chunks_len = cellfun(@(chunk) length(chunk), chunks, 'UniformOutput', 0);
    % calculate temporal profile automatically if all the chunks have the same
    % length
    if length(unique(cell2mat(chunks_len))) == 1 && length(chunks) > 1 && size(chunks{1}, 1) > 1
        is_cal_temporal = 1;
        time_base = chunks{1};
        time_base = time_base(:,1);
    end

    if length(grouping) > 4 && strcmp(grouping(end-4:end), 'event') && ...
        isfield(args, 'whence') && isfield(args, 'interval')
        is_cal_temporal = 1;
        offset = args.interval(1);
        chunks_len_temp = vertcat(chunks_len{:});
        [max_v, max_idx] = max(chunks_len_temp);
        time_base = chunks{max_idx};
        time_base = time_base(:,1);
    end

    % [adjusted_chunks adjusted_time_base] = ...
    %     adjust_before_align(chunks, args.whence, args.interval);
    % temporal_chunk = align_streams(adjusted_time_base, ...
    %     adjusted_chunks, 'ForceZero');
    % temporal_chunk = round(temporal_chunk);
    time_base = 0:args.sample_rate:(args.interval(2)-args.interval(1)-0.01);
    temporal_chunk = align_streams(time_base, chunks, 'ForceZero');
    
    if isfield(args, 'nodata_marker')
        [res_temporal res_temporal_count] = probabilities_of_values(...
            temporal_chunk, args.nodata_marker);
    else
        [res_temporal res_temporal_count] = probabilities_of_values(...
            temporal_chunk);
    end
    
    results.temporal_time = time_base - time_base(1) + offset;
    % results.temporal_time = adjusted_time_base;
    results.temporal_probs = res_temporal;
    results.temporal_chunk = temporal_chunk;
    results.temporal_count = res_temporal_count;
end

% disp(['For all the events statistics, please extract event data chunks,' ...
%     ' and call function event_cal_stats']);

is_cal_event_stats = true;
if is_cal_event_stats
    % convert to events
    event_chunks = cellfun(@(chunk_one) ...
        stream2event(chunk_one, sample_rate), ...
        chunks, ...
        'UniformOutput', false);
    args_events = args;
    event_stats = event_cal_stats(event_chunks, args_events);

    results.trans_matrix = event_stats.trans_matrix;
    results.individual_trans_matrix = event_stats.individual_trans_matrix;
    results.EVENT_STATS = '----------convert to events from here-----------';
    results.event_stats = event_stats;
end

