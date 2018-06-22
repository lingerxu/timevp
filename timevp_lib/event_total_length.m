function t_len = event_total_length(events)
% event_total_length  Return the sum of the durations of all the periods
% of the given event.
%   USAGE: p = event_proportion(event, scope)
%
t_len = 0;
if ~isempty(events)
    t_len = sum(events(:,2) - events(:,1));
end