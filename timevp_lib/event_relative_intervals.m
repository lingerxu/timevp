function relative_intervals = event_relative_intervals(event, whence, interval)
% event_relative_intervals - find time relative to start or end of events
% This function just calls cevent_relative_intervals.m
% 
% USAGE:
% event_relative_intervals(event, 'start', [-5 0])
%   Make a new event.  For each instance of the original event, make a new
%   instance that's the 5 seconds before the event starts, up to the moment
%   the event starts.
%
% See also: CEVENT_RELATIVE_INTERVALS

relative_intervals = cevent_relative_intervals(event, whence, interval);