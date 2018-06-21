function data_target = get_matching_segments(data_segments, data_event)

is_data_cell = iscell(data_segments);

if is_data_cell
    num_segments = length(data_segments);
    num_events = size(data_event, 1);

    if num_segments ~= num_events
        error('Invalid input. The number of segments should be the same as the number of events.')
    end

    data_target = cell(num_segments, 1);

    for sgidx = 1:num_segments
        segment_one = data_segments{sgidx};
        target_code = data_event(sgidx, end);
        segment_target = segment_one(segment_one(:,end) == target_code, :);
        data_target{sgidx} = segment_target;
    end
else
    num_events = size(data_event, 1);
    if num_events ~= 1
        error('Invalid input. When data is one matrix, the function can only take in 1 event.')
    end
    target_code = data_event(1, end);
    data_target = data_segments(data_segments(:,end) == target_code, :);
end