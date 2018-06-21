function relative_intervals = cevent_relative_intervals(cevent, whence, interval)
% cevent_relative_intervals - find time relative to start or end of event
%
% cevent_relative_intervals(cevent, 'start', [-5 0])
%   Make a new cevent.  For each instance of the original event, make a new
%   instance that's the 5 seconds before the event starts, up to the moment
%   the event starts.  Each new event will have the same ID as the original
%   event that it was based on.
%
% cevent_relative_intervals(cevent, 'end', [-2 3])
%   Make a new cevent, with the time bounds as 2 seconds before to 3
%   seconds after the end of the original event.
%
% cevent_relative_intervals(cevent, 'startend', [1, -1])
%   Make a new cevent, which is like the original event, but "shrunken" by
%   1 second on each end.  WARNING: this may lead to an event with negative
%   length, if the original event is less than 2 seconds long.
%   (cevent_relative_intervals will emit a warning in this case)
%
% If the input variable is a plain event (2 columns) rather than a cevent
% (3 columns), that's handled, and the output will also be a 2-column
% event.
%
% The most straightforward way to use the function is to create another
% cevent, by having the INTERVAL argument be two elements long.  However,
% if you just wanted to find out a single point in time for each event, you
% could specify an INTERVAL like [-3], just one element long.  Or you could
% specify an INTERVAL that had 3 elements.  I don't know if this would be
% useful, but it was easy to write the function this way, so I'll just go
% ahead and document it.
%
% Example:
%
% >> cevent = [0 10 1; 20 21 2; 80 85 3]
% cevent =
%      0    10     1
%     20    21     2
%     80    85     3
%
% >> cevent_relative_intervals(cevent, 'start', [-1 1]) 
% ans =
%     -1     1     1
%     19    21     2
%     79    81     3
% 
% >> cevent_relative_intervals(cevent, 'end', [-1 1])
% ans =
%      9    11     1
%     20    22     2
%     84    86     3
%
% >> % Add 0 to start time and 0 to end time:
% >> % Should get the cevent back with no changes
% >> isequal(cevent, cevent_relative_intervals(cevent, 'startend', [0 0]))
% ans = 1
%
% >> % Make an event with negative length
% >> cevent_relative_intervals(cevent, 'startend', [5 -5])
% Warning: You seem to have constructed an event that ends before it
% begins!
% ***
%

% find what thing we should use to calculate the times from
switch whence
    case 'start'
        basis = cevent(:, 1);
    case 'end'
        basis = cevent(:, 2);
    case 'startend'
        % Will call this function again with a different WHENCE argument.
        relative_intervals = do_startend(cevent, interval);
        return
        
    otherwise
        error('The WHENCE argument must be either ''start'' or ''end''.');
end

% make the time columns by adding each element of the interval to each
% element of the time, in the correct column
[time_grid, offset_grid] = ndgrid(interval, basis);
timestamps = time_grid' + offset_grid';


if size(cevent, 2) > 2
    relative_intervals = [timestamps cevent(:, 3:end)];
else
    relative_intervals = timestamps;
end

check_non_negative(relative_intervals, numel(interval));
end



function relative_intervals = do_startend(cevent, interval)
% deal with the specialness of doing one part from the start and one from
% the end

if size(interval) ~= [1,2]
    error('For a ''startend'' interval, the INTERVAL argument must be a 1x2 matrix.');
end

from_start = cevent_relative_intervals(cevent, 'start', interval(1));

from_end = cevent_relative_intervals(cevent, 'end', interval(2));

% there's a duplicate of the category column so you have to do (:,1)
relative_intervals = horzcat(from_start(:, 1), from_end);

check_non_negative(relative_intervals, 2);
end


function check_non_negative(relative_intervals, time_columns)
% Make sure that, for all the events E, the start time of E is before the
% end time of E.

if ~ all(diff(relative_intervals(:, 1:time_columns), 1, 2) >= 0)
    warning('cevent_relative_intervals:negative_event_duration', ...
        'You seem to have constructed an event that ends before it begins!');
end
end

