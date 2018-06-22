function [res] = cevent_remove_long_segments(cevent, maxDuration)
% cevent_remove_long_segments deletes event intervals that are too long
%
% takes a list of cevent instances in a cevent variable and return a new 
% list by removing those instances with long durations.
% 
% cevent_remove_long_segments(cevent, maxDuration)
% Input:
%   cevent: a cevent varible
%   maxDuration: the duration threshold (should be in sec in a general
%   case)
% Outout:
%   A new cevent variable without long instances. 



logical = (cevent(:, 2) - cevent(:, 1)) <= maxDuration;
res = cevent(logical, :);

