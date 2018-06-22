function result_stats = timevp_compute_statistics(variable_name, subject_list, args)

if nargin < 3
    args = struct();
end
    
num_subs = length(subject_list);
is_event = false;

[chunks, extra_info] = get_data_by_subject(subject_list, variable_name, args);
num_cols_data = extra_info.num_cols_data;

if length(num_cols_data) > 1
    warning(['There are both stream and event type data in the put. Function will '...
        'now transform all stream data into event type data.']);
    
    if isfield(args, 'sample_rate')
        sample_rate = args.sample_rate;
    else
        sample_rate = timevp_config_dataset_info();
    end

    for cidx = 1:num_subs
        data_one = chunks{cidx};
        chunks{cidx} = stream2event(data_one, sample_rate);
    end
    
    is_event = true;
elseif num_cols_data == 3
    is_event = true;
end

if isfield(extra_info, 'ranges')
    ranges = extra_info.ranges;
    individual_range_dur = nan(num_subs, 1);
    for sidx = 1:num_subs
        range_one = ranges{sidx};
        individual_range_dur(sidx, 1) = sum(range_one(:,2) - range_one(:,1));
    end
    args.individual_range_dur = individual_range_dur;
end

args.subject_list = subject_list;

if is_event
    result_stats = event_cal_stats(chunks, args);
else
    result_stats = stream_cal_stats(chunks, args);
end

result_stats.data_list = chunks;