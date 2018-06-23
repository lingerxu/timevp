function out = stream_category_equals(streams, categories)
%Makes a cevent variable with only some of the instances in the input cevent
%   USAGE:
%   stream_category_equals(STREAMS, CATEGORIES)
%       Finds all the data points in STREAMS that have their categories equal to
%       one of the numbers in CATEGORIES (which could be just a single
%       number), and returns a new variable with only those instances.
%
%   STREAMS should be n by 2 or 3 matrix.
%
%   CATEGORIES should be a single integer, or a list of integers, which are
%   the categories in EVENTS that you want to preserve.
%
%   The return value is a single event variable.
%

if isempty(streams)
    out = [];
else
    out = streams(ismember(streams(:, end), categories), :);
end

