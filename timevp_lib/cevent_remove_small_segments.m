function [res] = cevent_remove_small_segments(cevent, minDuration)
% cevent_remove_small_segments deletes event intervals that are too small
%
% takes a list of cevent instances in a cevent variable and return a new 
% list by removing those instances with small durations.
% 
% cevent_remove_small_segments(cevent, minDuration)
% Input:
%   cevent: a cevent varible
%   minDuration: the duration threshold (should be in sec in a general
%   case)
% Outout:
%   A new cevent variable without short instances. 



logical = (cevent(:, 2) - cevent(:, 1)) >= minDuration;
res = cevent(logical, :);

