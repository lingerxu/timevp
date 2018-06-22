function [dur] = event_average_dur(cevent)
% Finds the average length of an event (or cevent)  
% event_average_dur(EVENT_DATA)
  
if isempty(cevent)
    dur = NaN;
else
    dur = mean(cevent(:,2) - cevent(:,1));
end
