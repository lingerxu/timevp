function events_out = get_event_opposite(event_data, ranges, sub_id)

% This function get the durations that are not within the event ranges but
% still within trials, return as events. The input data can have
% overlapping events.

if ~exist('ranges', 'var')
    ranges = get_ranges(sub_id);
end

has_overlap = check_ranges_overlap(event_data);
if has_overlap
    error('There are overlaps in events. Currently cannot handle this situation. Please contact txu@indiana.edu');
end

events_out = [];
chunks_event = extract_ranges(event_data, 'event', ranges);

for ridx = 1:size(ranges, 1)
    range_one = ranges(ridx, :);
    events_one = chunks_event{ridx};
    events_one = event_sort_by_time(events_one, 1);
    
    tmp = [range_one; events_one(:,1:2)];
    tmp(1:end-1, 2) = events_one(:, 1);
    tmp(2:end, 1) = events_one(:, 2);
    tmp(end, 2) = range_one(1, 2);
    
    events_out = [events_out; tmp];
end
