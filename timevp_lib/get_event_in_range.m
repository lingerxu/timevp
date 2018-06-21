function event_in_range = get_event_in_range(event, range)
%event_in_range: Return part of the events that is in the range
%   USAGE: event_in_range = get_event_in_scope(event, range)
%   Input:
%     event: (binary) event data;
%     range: the range 
%   Output:
%     event_in_range:   part of the events that is in the range

if isempty(event)
    event_in_range = [];
    return
end

start_too_late = event(:, 1) > range(2);
end_too_soon = event(:, 2) < range(1);
omit = start_too_late | end_too_soon;

shaggy = event(~omit, :);

% now we trim it..
event_in_range = [ max(shaggy(:, 1), range(1)) , min(shaggy(:, 2), range(2)) ];
if size(shaggy, 2) > 2
    event_in_range = [ event_in_range, shaggy(:, 3:end) ];
end
