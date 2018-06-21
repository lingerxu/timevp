function results = cevent_cal_stats(chunks, args)
%CEVENT_CAL_STATS Report various stypes of statistics of cevent data
%chunks according to user args.
% 
% INPUT: 
%   CHUNKS: a cell of data. See also GET_VARIABLE,
%   GET_VARIABLE_BY_GROUPING, GET_VARIABLE_BY_SUBJECT,
%   GET_VARIABLE_BY_TRIAL, GET_VARIABLE_BY_EVENT, GET_VARIABLE_BY_CEVENT.
%   INPUT: (optional parameter) a struct that specifies the types of
%   statistics user wants to calculate. Optional fields are: 
%       grouping: the grouping method of data chunks, see 
%       GET_VARIABLE_BY_GROUPING;
%       categories: categories existing in the data chunks;
%       nodata_marker: which category value will be considered as non-data
%       in generating transition matrix;
%       trans_max_gap: the maximum timing gap that is allowed for two
%       cevents to be considered as consecutive events in generating
%       transition matrix;
%       individual_range_dur: only when data chunks are extracted in
%       grouping method 'trial' or 'subject', this field is allowed. And,
%       the existence of this field will lead to calculation of proportion
%       and frequency in results.
%       hist_bins: bins for generating histogram according to categories.
%       high_threshold: for calculating the proportion of time that data
%       has a category value larger than this category value**;
%       low_threshold:
%       whence: value 'start' or 'end', indicating whether the chunks of
%       data were extracted based on onset/offser of a certain types of
%       events/cevents.
%       interval: used with the parameter WHENCE, indicating the starting 
%       time and ending time when chunks were extracted based on
%       events/cevents.
% 
% OUTPUT:
%   RESULTS: a struct containing all the statistics. Also, individual
%   statistic within one chunk of data will be reported.
% 
% EXAMPLE:
%     exp_id = 53;
%     sub_list = list_subjects(exp_id);
% 
%     args.sub_list = sub_list;
%     args.var_name = 'cevent_human_eye_roi';
%     args.grouping = 'trial';
% 
%     chunks = get_variable_by_grouping('sub', args.sub_list, args.var_name, ...
%         args.grouping, args);
% 
%     chunks_trial_time = arrayfun(@(sub_id) ...
%         get_trial_times(sub_id), ...
%         args.sub_list, ...
%         'UniformOutput', false);
%     individual_range_dur = vertcat(chunks_trial_time{:});
%     individual_range_dur = individual_range_dur(:,2) - individual_range_dur(:,1);
%     args.individual_range_dur = individual_range_dur;
% 
%     results = cevent_cal_stats(chunks, args);
% Example results:
%     results = 
%                       categories: [1 2 3 4]
%                     total_number: 6459
%                individual_number: [59x1 double]
%              total_number_by_cat: [1286 1902 1279 1992]
%         individual_number_by_cat: [59x4 double]
%                         mean_dur: 0.9074
%              individual_mean_dur: [59x1 double]
%                  mean_dur_by_cat: [1.2025 0.8770 1.1315 0.6020]
%       individual_mean_dur_by_cat: [59x4 double]
%                       median_dur: 0.4220
%                median_dur_by_cat: [0.5160 0.3600 0.4690 0.4210]
%                             prop: 0.8279
%                      prop_by_cat: [0.2639 0.2846 0.2469 0.2046]
%                  individual_prop: [59x1 double]
%           individual_prop_by_cat: [59x4 double]
%                             freq: 54.7462
%                      freq_by_cat: [10.9001 16.1213 10.8408 16.8841]
%                  individual_freq: [59x1 double]
%           individual_freq_by_cat: [59x4 double]
%                 range_time_total: 7.0788e+003
%            individual_range_dur: [59x1 double]
%                         switches: 43.6512
%              individual_switches: [59x1 double]
%                     trans_matrix: [4x4 double]
%          individual_trans_matrix: {59x1 cell}
%                trans_freq_matrix: [4x4 double]
%     individual_trans_freq_matrix: {59x1 cell}
%
%   See also: EVENT_SINGLE_STATS, GET_VARIABLE_BY_GROUPING
% 
% For more example, go to: 
% https://einstein.psych.indiana.edu/trac/browser/projects/txu_remodule/txu_test_stats_cevent.m

if isempty(chunks)
    warning('The args CHUNKS is empty, there is no data inside, the function will return now');
    results = [];
    return
end

% check fileds in 'args'
if ~exist('args', 'var')
    % this line of code is just to prevent from generating errors when
    % script checks whether a certain field exists.
    args.none_filed = 'No information here';
end

% if isfield(args, 'var_name')
%     if ~strcmp(get_data_type(args.var_name), 'cevent')
%         error('Error! This function can only accept CEVENT data type');
%     end
% end

if isfield(args, 'sub_list')
    results.sub_list = args.sub_list;
end

if isfield(args, 'grouping')
    grouping = args.grouping;
else
    grouping = '';
end

% If user only wants to calculate stats for cevents that fall within a
% specified duration range
if isfield(args, 'min_dur_thresh')
    for cidx = 1:length(chunks)
        chunk_one = chunks{cidx};
        if size(chunk_one, 1) > 0
            chunk_one = cevent_remove_small_segments(...
                chunk_one, args.min_dur_thresh);
        end
        chunks{cidx} = chunk_one;
    end
end

if isfield(args, 'max_dur_thresh') 
    for cidx = 1:length(chunks)
        chunk_one = chunks{cidx};
        if size(chunk_one, 1) > 0
            chunk_one = cevent_remove_long_segments(...
                chunk_one, args.max_dur_thresh);
        end
        chunks{cidx} = chunk_one;
    end
end

cat_chunks = cat(1,chunks{:});

if isfield(args, 'categories')
    categories = args.categories;
    categories = categories(~isnan(categories));
    results.categories = categories;
else
    categories = unique(cat_chunks(:,3))';
    categories = categories(~isnan(categories));
    if isfield(args, 'nodata_marker')
        categories = categories(~ismember(categories, args.nodata_marker));
    end
    results.categories = categories;
end

if all(cellfun(@isempty, chunks))
    max_category = 1;
else
    max_category = nanmax(nanmax(cat_chunks(:,3)), max(categories));
end

% the calculation of individual_range_dur should be done
% in the step of extracting data
if isfield(args, 'individual_ranges')
    args.individual_range_dur = args.individual_ranges(:,2) - args.individual_ranges(:,1);
end

if isfield(args, 'individual_range_dur')
    individual_range_dur = args.individual_range_dur;
    
    if size(individual_range_dur, 1) == 1
        individual_range_dur = repmat(individual_range_dur, ...
            length(chunks), 1);
        args.individual_range_dur = individual_range_dur;
    elseif length(chunks) ~= length(individual_range_dur)
        warning(['Warning: the length of data chunks and the length ' ...
            'of individual_range_dur are not the same, therefore, ' ...
            'args.individual_range_dur will be discarded.']);
        args = rmfield(args, 'individual_range_dur');
    end
elseif strcmp(grouping, 'subject') && isfield(args, 'sub_list') ...
        && length(chunks) == length(args.sub_list)
    chunks_trial_time = arrayfun(@(sub_id) ...
        event_total_length(get_trial_times(sub_id)), ...
        args.sub_list, ...
        'UniformOutput', false);
    individual_range_dur = vertcat(chunks_trial_time{:});
    args.individual_range_dur = individual_range_dur;
elseif strcmp(grouping, 'trial_cat') && isfield(args, 'sub_list') ...
        && length(chunks) == length(args.sub_list)
    chunks_trial_time = arrayfun(@(sub_id) ...
        event_total_length(get_trial_times(sub_id)), ...
        args.sub_list, ...
        'UniformOutput', false);
    individual_range_dur = vertcat(chunks_trial_time{:});
    args.individual_range_dur = individual_range_dur;
elseif strcmp(grouping, 'trial') && isfield(args, 'sub_list') ...
        && (~isfield(args, 'trial_indices') && ~isfield(args, 'trial_var_name'))
    chunks_trial_time = arrayfun(@(sub_id) ...
        get_trial_times(sub_id), ...
        args.sub_list, ...
        'UniformOutput', false);
    individual_range_dur = vertcat(chunks_trial_time{:});
    individual_range_dur = individual_range_dur(:,2)-individual_range_dur(:,1);
    if length(individual_range_dur) == length(chunks)
        args.individual_range_dur = individual_range_dur;
    else
        disp(['If chunks are extracted based on selective trials, ' ...
            'either the field trial_indices or trial_var_name has to be set']);
    end
elseif strcmp(grouping, 'trial') && isfield(args, 'sub_list') ...
        && isfield(args, 'trial_indices') && ~isfield(args, 'trial_var_name')
    sub_list = args.sub_list;
    individual_range_dur = [];
    
    for sidx = 1:length(sub_list)
        sub_id = sub_list(sidx);
        if iscell(args.trial_indices)
            trial_indices_one = args.trial_indices{sidx};
        else
            trial_indices_one = args.trial_indices;
        end
        trial_times_one = get_trial_times(sub_id, trial_indices_one);
        trial_times_one = trial_times_one(:,2)-trial_times_one(:,1);
        individual_range_dur = [individual_range_dur; trial_times_one];
    end
    args.individual_range_dur = individual_range_dur;
elseif strcmp(grouping, 'trial') && isfield(args, 'sub_list') ...
        && ~isfield(args, 'trial_indices') && isfield(args, 'trial_var_name')
    sub_list = args.sub_list;
    individual_range_dur = [];
    
    for sidx = 1:length(sub_list)
        sub_id = sub_list(sidx);
        if iscell(args.trial_indices)
            trial_indices_one = args.trial_indices{sidx};
        else
            trial_indices_one = args.trial_indices;
        end
        trial_times_one = get_trial_times(sub_id, trial_indices_one);
        trial_times_one = trial_times_one(:,2)-trial_times_one(:,1);
        individual_range_dur = [individual_range_dur; trial_times_one];
    end
    args.individual_range_dur = individual_range_dur;
end

%% calculate statistics
cat_chunks_by_cat = arrayfun(@(category_one) ...
    cevent_category_equals(cat_chunks, category_one), ...
    categories, ...
    'UniformOutput', false);

cat_chunks = cevent_category_equals(cat_chunks, categories);
cat_durations = cat_chunks(:,2) - cat_chunks(:,1);

if sum(ismember([0 NaN], unique(cat_chunks(:,3)))) > 0
    warning(['This cevent variable contains category value 0, ' ...
        'transition matrix cannot be calculated']);
    has_transition_matrix = false;
else
    has_transition_matrix = true;
end

% loop through each chunk for calculating some statistics
individual_number = zeros(length(chunks), 1);
individual_number_by_cat = zeros(length(chunks), length(categories));
individual_mean_dur = nan(length(chunks), 1);
individual_std_dur = nan(length(chunks), 1);
individual_median_dur = nan(length(chunks), 1);
individual_mean_dur_by_cat = nan(length(chunks), length(categories));
individual_median_dur_by_cat = nan(length(chunks), length(categories));
% individual_stats = cell(length(chunks), 1);

res_trans_matrix = zeros(length(categories), length(categories));
res_individual_trans_matrix = cell(length(chunks), 1);
res_individual_trans_freq_matrix = cell(length(chunks), 1);

for chunkidx = 1:length(chunks)
    chunk_one = chunks{chunkidx};    
    
    if ~isempty(chunk_one)
        chunk_one = cevent_category_equals(chunk_one, categories);
    end
    
    if isempty(chunk_one)
        chunk_one = zeros(0, 3);
        chunk_one_by_cat = mat2cell(repmat(zeros(0, 3), 4, 1), ....
            zeros(1, 4), [3]);
        res_individual_trans_matrix{chunkidx} = [];
    end
    
    for catidx = 1:length(categories)
        category_one = cevent_category_equals( ...
            chunk_one, categories(catidx));
        
        individual_number_by_cat(chunkidx, catidx) = ...
            event_number(category_one);
        individual_mean_dur_by_cat(chunkidx, catidx) = ...
            event_average_dur(category_one);
        individual_median_dur_by_cat(chunkidx, catidx) = ...
            event_median_dur(category_one);
        
        chunk_one_by_cat = arrayfun(@(category_id) ...
            cevent_category_equals(chunk_one, category_id), ...
            categories, ...
            'UniformOutput', false);
    end
    
    individual_number(chunkidx) = event_number(chunk_one);
    individual_mean_dur(chunkidx) = event_average_dur(chunk_one);
    if isempty(chunk_one)
        individual_std_dur(chunkidx) = NaN;
    else
        individual_std_dur(chunkidx) = std(chunk_one(:,2) - chunk_one(:,1));
    end
    individual_median_dur(chunkidx) = event_median_dur(chunk_one);
    
    if has_transition_matrix
        if isempty(chunk_one)
            res_individual_trans_matrix{chunkidx} = ...
                zeros(length(categories), length(categories));
            
            if isfield(args, 'individual_range_dur')
                res_individual_trans_freq_matrix{chunkidx} = ...
                    zeros(length(categories), length(categories));
            end

        else
            % for calculating transition matrix for each chunk
            if isfield(args, 'trans_max_gap')        
                trans_matrix_one = cevent_transition_matrix(chunk_one, ...
                    args.trans_max_gap, max_category);
            else
                trans_matrix_one = cevent_transition_matrix(chunk_one, ...
                    Inf, max_category);
            end
            
            res_trans_matrix = res_trans_matrix + ...
                trans_matrix_one(categories, categories);

            res_individual_trans_matrix{chunkidx} = ...
                trans_matrix_one(categories, categories);

            if isfield(args, 'individual_range_dur')
                res_individual_trans_freq_matrix{chunkidx} = ...
                    trans_matrix_one(categories, categories) / ...
                    individual_range_dur(chunkidx) * 60; % per minute
            end
        end
    end
    % temp_indiv_stats.trans_matrix = res_individual_trans_matrix{chunkidx};
    % individual_stats(chunkidx) = temp_indiv_stats;    
end

% number of events
% total number
results.total_number = event_number(cat_chunks);
results.individual_number = individual_number;
% number by category
res_total_number_by_cat = cellfun(@event_number,cat_chunks_by_cat, ...
    'UniformOutput', false);
results.total_number_by_cat = horzcat(res_total_number_by_cat{:});
results.individual_number_by_cat = individual_number_by_cat;

% mean duration
% overal mean
results.mean_dur = event_average_dur(cat_chunks);
results.individual_mean_dur = individual_mean_dur;
results.individual_std_dur = individual_std_dur;
% mean by category
res_mean_dur_by_cat = cellfun(@event_average_dur, cat_chunks_by_cat, ...
    'UniformOutput', false);
results.mean_dur_by_cat = horzcat(res_mean_dur_by_cat{:});
results.individual_mean_dur_by_cat = individual_mean_dur_by_cat;

% median durations
results.median_dur = event_median_dur(cat_chunks);
results.individual_median_dur = individual_median_dur;
res_median_dur_by_cat = cellfun(@event_median_dur, cat_chunks_by_cat, ...
    'UniformOutput', false);
results.median_dur_by_cat = horzcat(res_median_dur_by_cat{:});
results.individual_median_dur_by_cat = individual_median_dur_by_cat;

% proportion and frequency are only calculated when individual trial
% time is included in args
if isfield(args, 'individual_range_dur')
    range_time_total = nansum(individual_range_dur);
    mean_dur_tmp = results.mean_dur;
    mean_dur_tmp(isnan(mean_dur_tmp)) = 0;
    mean_dur_by_cat_tmp = results.mean_dur_by_cat;
    mean_dur_by_cat_tmp(isnan(mean_dur_by_cat_tmp)) = 0;
    indiv_mean_dur_tmp = individual_mean_dur;
    indiv_mean_dur_tmp(isnan(individual_mean_dur)) = 0;
    indiv_mean_dur_by_cat_tmp = individual_mean_dur_by_cat;
    indiv_mean_dur_by_cat_tmp(isnan(individual_mean_dur_by_cat)) = 0;
    
    % proportions
    results.prop = mean_dur_tmp * results.total_number / range_time_total;
    results.prop_by_cat = mean_dur_by_cat_tmp .* ...
        results.total_number_by_cat / range_time_total;
    results.individual_prop = (indiv_mean_dur_tmp .* ...
        results.individual_number) ./ individual_range_dur;
    results.individual_prop_by_cat = (indiv_mean_dur_by_cat_tmp .* results.individual_number_by_cat) ...
        ./ repmat(individual_range_dur, 1, length(categories));

    % mean proportions
    results.mean_prop = nanmean(results.individual_prop);
    results.mean_prop_by_cat = nanmean(results.individual_prop_by_cat, 1);
    
    % frequency
    results.freq = results.total_number / (range_time_total/60);
    results.freq_by_cat = results.total_number_by_cat / (range_time_total/60);
    results.individual_freq = results.individual_number ./ (individual_range_dur/60);
    results.individual_freq_by_cat = results.individual_number_by_cat ...
        ./ repmat((individual_range_dur/60), 1, length(categories));
    
    results.range_time_total = range_time_total;
    results.individual_range_dur = individual_range_dur;
end

% number of switches between categories
individual_switches = cellfun(@(chunk) ...
    cevent_number_switches(chunk, categories), ...
    chunks, ...
    'UniformOutput', false);
individual_switches = vertcat(individual_switches{:});
% results.switches = nansum(individual_switches);
% results.individual_switches = individual_switches;
if isfield(args, 'individual_range_dur')
    results.switches_freq = nansum(individual_switches) / (range_time_total/60);
    results.individual_switches_freq = individual_switches ./ ...
        (args.individual_range_dur/60);
else
    results.switches = nansum(individual_switches);
    results.individual_switches = individual_switches;
end

% hist_bins
if isfield(args, 'hist_arg')
    hist_arg = args.hist_arg;
else
    hist_arg = 'thresholds';
end

if isfield(args, 'hist_bins')
    res_dur_hist = nan(length(chunks), length(args.hist_bins));
    for i = 1: length(chunks)
        res_dur_hist(i,:) = event_duration_hist(chunks{i}, args.hist_bins, hist_arg);
        res_dur_hist(i,:) = res_dur_hist(i,:)/sum(res_dur_hist(i,:));
    end
       
    results.dur_hist = event_duration_hist(cat_chunks, args.hist_bins, hist_arg);
    results.dur_hist = results.dur_hist/sum(results.dur_hist);
    results.individual_dur_hist = res_dur_hist;
end

% low shreshold
if isfield(args, 'low_threshold')
    res_low_prop = nan(length(chunks), 1);    
    for i = 1: length(chunks)
        durations_one = chunks{i};
        durations_one = durations_one(:,2) - durations_one(:,1);
        res_low_prop(i) = sum(durations_one < args.low_threshold) ...
            / length(durations_one);
    end
    
    results.dur_low_prop = sum(cat_durations < args.low_threshold) ...
        / length(cat_durations);
    results.individual_dur_low_prop = res_low_prop;
end

% high shreshold
if isfield(args, 'high_threshold')
    res_high_prop = nan(length(chunks), 1);    
    for i = 1: length(chunks)
        durations_one = chunks{i};
        durations_one = durations_one(:,2) - durations_one(:,1);
        res_high_prop(i) = sum(durations_one > args.high_threshold) ...
            / length(durations_one);
    end
    
    results.dur_high_prop = sum(cat_durations > args.high_threshold) ...
        / length(cat_durations);
    results.individual_dur_high_prop = res_high_prop;
end

% add transition matrix to results
if has_transition_matrix
    results.trans_matrix = res_trans_matrix;
%     results.individual_trans_matrix_cell = res_individual_trans_matrix;
    
    size_trans_matrix = size(res_trans_matrix, 1);
    res_tmp_mat_frow = cell(1, size_trans_matrix*size_trans_matrix);
    
    for cfidx = 1:length(categories)
        first_num = categories(cfidx);
        
        for csidx = 1:length(categories)
            second_num = categories(csidx);
            tmp_str = sprintf('%dto%d', first_num, second_num);
            res_tmp_mat_frow{1,(cfidx-1)*length(categories)+csidx} ...
                = tmp_str;
        end
    end
    
    res_tmp_mat = zeros(length(chunks), ...
        size_trans_matrix*size_trans_matrix);
    
    for cidx = 1:length(chunks)
        tmp_mat = res_individual_trans_matrix{cidx};
        tmp_mat = tmp_mat';
        res_tmp_mat(cidx,:) = tmp_mat(:)';
    end
    
    results.individual_trans_matrix = ...
        vertcat(res_tmp_mat_frow, num2cell(res_tmp_mat));
    
    if isfield(args, 'individual_range_dur')
        res_trans_matrix = res_trans_matrix / (range_time_total/60);
    end
    results.trans_freq_matrix = res_trans_matrix;
    if isfield(args, 'individual_range_dur')
        res_tmp_mat = nan(length(chunks), ...
            size_trans_matrix*size_trans_matrix);

        for cidx = 1:length(chunks)
            tmp_mat = res_individual_trans_freq_matrix{cidx};
            res_tmp_mat(cidx,:) = tmp_mat(:)';
        end

        results.individual_trans_freq_matrix = ...
            vertcat(res_tmp_mat_frow, num2cell(res_tmp_mat));
    end
end
    

%% adding the code to replace props and frquency with zeros
