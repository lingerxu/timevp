function [data, extra_info] = get_data_by_subject(subject_list, var_name, args)
% This function fetches data by subject ID and variable name

if nargin < 3
    args = struct([]);
end

if isfield(args, 'sample_rate')
    sample_rate = args.sample_rate;
else
    [~, sample_rate] = timevp_config_dataset_info();
end

num_subs = length(subject_list);
num_cols_data = nan(num_subs, 1);
chunks = cell(num_subs, 1);
data = [];
if ~isfield(args, 'categories')
    categories = [];
end
if isfield(args, 'segment_event')
    ranges = cell(num_subs, 1);
end

for sidx = 1:num_subs
    sub_id = subject_list(sidx);
    data_one = get_variable_data(sub_id, var_name);
    
    if isempty(data_one)
        continue
    end

    size_one = size(data_one, 2);
    
    if size_one ~= 2 && size_one ~= 3
        error(['This function only accept stream [timestamp value] or '...
            'event [onset offset value] as input.']);
    end

    if size_one == 3 && isfield(args, 'convert_event2stream') && args.convert_event2stream
        data_one = event2stream(data_one, sample_rate);
        size_one = size(data_one, 2);
    end
    
    num_cols_data(sidx) = size_one;
    
    if isfield(args, 'categories')
        data_one = stream_category_equals(data_one, args.categories);
    else
        categories = [categories; data_one(:,end)];
    end
    
    if isfield(args, 'segment_event')
        events_one = get_variable_data(sub_id, args.segment_event);
        if size(events_one, 2) == 2
            events_one = stream2event(events_one, sample_rate);
        end
        
        if isfield(args, 'event_values')
            events_one = event_category_equals(events_one, args.event_values);
        end
        
        if isempty(events_one)
            continue
        end
        
        [extracted_data, extracted_info] = extract_ranges(data_one, events_one, args);
        chunks{sidx} = extracted_data;
        ranges{sidx} = extracted_info.ranges;
    elseif isfield(args, 'ranges')
        ranges = args.ranges;
        if ~iscell(ranges)
            ranges = repmat({ranges}, num_subs, 1);
        end
        if length(ranges) ~= num_subs
            error('The number of ranges needs to be the same as the number of subjects. Function exit.')
        end
        range_one = ranges{sidx};
        [extracted_data, extracted_info] = extract_ranges(data_one, range_one, args);
        if size(range_one, 1) == 1
            chunks{sidx} = extracted_data{1};
        else
            chunks{sidx} = extracted_data;
        end
        ranges{sidx} = extracted_info.ranges;
    else
        chunks{sidx} = data_one;
    end
    
end

if num_subs > 1
    num_cols_data = unique(num_cols_data(num_cols_data > 0));
    data = chunks;
else
    data = chunks{1};
end

if ~isfield(args, 'categories')
    categories = unique(categories(~isnan(categories)));
end

extra_info.num_cols_data = num_cols_data;
if isfield(args, 'categories')
    extra_info.categories = args.categories;
else
    extra_info.categories = categories';
end

if isfield(args, 'segment_event') || isfield(args, 'ranges')
    extra_info.ranges = ranges;
    if num_subs == 1
        extra_info.ranges = ranges{1};
    end
end