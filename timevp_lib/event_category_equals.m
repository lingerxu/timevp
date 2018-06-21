function out = event_category_equals(events, categories)
%Makes a cevent variable with only some of the instances in the input cevent
%   USAGE:
%   event_category_equals(EVENTS, CATEGORIES)
%       Finds all the events in EVENTS that have their categories equal to
%       one of the numbers in CATEGORIES (which could be just a single
%       number), and returns a new cevent variable with only those instances.
%
%   EVENTS should be n by 3 matrix: [start_time end_time category value].
%
%   CATEGORIES should be a single integer, or a list of integers, which are
%   the categories in EVENTS that you want to preserve.
%
%   The return value is a single event variable.
%

if isempty(events)
    out = [];
else
    out = events(ismember(events(:, 3), categories), :);
end

