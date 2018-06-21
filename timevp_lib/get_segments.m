function [data_segments_list, data_events_list] = get_segments(subject_list, var_name, segment_event, event_values, is_value_matching)

num_subs = length(subject_list);

if nargin < 5
    is_value_matching = false;
end

if nargin < 4
    event_values = [];
end

if num_subs > 1
    data_segments_list = cell(num_subs, 1);
    data_events_list = cell(num_subs, 1);
end

for sidx = 1:num_subs
    sub_id = subject_list(sidx);
    data_variable = get_data_by_subject(sub_id, var_name);
    
    % read in event variable that will be used for segmenting the stream variable
    % read in the variable in stream form first, then convert the stream
    % into event intervals
    if ischar(segment_event)
        data_events = get_data_by_subject(sub_id, segment_event);
        num_col = size(data_events, 2);
        if num_col ~= 3
            error('Variable used for segmenting other variables should be in EVENT type: [start_time end_time categorical_value].')
        end
    else
        data_events = segment_event;
    end
    
    if ~isempty(event_values)
        data_events = event_category_equals(data_events, event_values);
    end

    data_segments = extract_ranges(data_variable, data_events, is_value_matching);
    
    if num_subs > 1
        data_segments_list{sidx} = data_segments;
        data_events_list{sidx} = data_events;
    end
end

if num_subs == 1
    data_segments_list = data_segments;
else
    data_events_list = data_events;
end
